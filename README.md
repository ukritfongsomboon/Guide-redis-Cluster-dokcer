# Redis Cluster Setup

Redis Cluster ที่มีการยืนยัตว์ด้วย username และ password พร้อม HAProxy load balancer

## ข้อกำหนดเบื้องต้น

- Docker
- Docker Compose
- Redis CLI (สำหรับการทดสอบแบบ manual)

## เริ่มต้นใช้งาน

### 1. ตั้งค่า Environment Variables

แก้ไขไฟล์ `.env`:

```bash
REDISCLI_AUTH_USERNAME=admin
REDISCLI_AUTH_PASSWORD=admin
```

ใช้ username และ password ตามต้องการของคุณ

### 2. เริ่มต้น Cluster

```bash
./start-cluster.sh
```

Script นี้จะทำการ:
- สร้างและเริ่มต้น 6 Redis nodes (3 masters, 3 slaves)
- ตั้งค่า HAProxy load balancer
- Initialize cluster
- เริ่มต้น Redis Insight

### 3. ทดสอบ Cluster

```bash
./test-cluster.sh
```

Script นี้จะทำการ:
- ตรวจสอบข้อมูล cluster
- แสดงรายชื่อ cluster nodes
- ทดสอบ SET/GET operations
- ทดสอบการเชื่อมต่อ direct node

### 4. หยุด Cluster

```bash
./stop-cluster.sh
```

## โครงสร้างไฟล์

| ไฟล์ | คำอธิบาย |
|------|---------|
| `.env` | ไฟล์การตั้งค่า username และ password (⚠️ อย่า commit) |
| `redis.sh` | Startup script สำหรับแต่ละ Redis node - สร้าง config และ ACL จาก env variables |
| `docker-compose.yaml` | Docker Compose configuration - กำหนด 6 Redis nodes, HAProxy, และ Redis Insight |
| `start-cluster.sh` | Script สำหรับเริ่มต้น cluster และ initialize |
| `stop-cluster.sh` | Script สำหรับหยุด cluster และลบ volumes |
| `test-cluster.sh` | Script สำหรับทดสอบ cluster functionality |
| `server.crt` | SSL Certificate (ไม่ใช้ในโครงสร้างปัจจุบัน) |
| `server.key` | SSL Private Key (ไม่ใช้ในโครงสร้างปัจจุบัน) |
| `dhparams.pem` | DH Parameters (ไม่ใช้ในโครงสร้างปัจจุบัน) |
| `haproxy/` | ไดเรกทอรี่การตั้งค่า HAProxy |
| `.gitignore` | Git ignore rules (ป้องกัน .env ไม่ให้ถูก commit) |
| `.env.example` | ตัวอย่าง environment variables |

## การเชื่อมต่อกับ Redis Insight

### ขั้นตอนที่ 1: เปิด Redis Insight

เข้าไปที่ **http://localhost:8001**

### ขั้นตอนที่ 2: Add Redis Database

1. คลิก **+ Add Redis Database**
2. เลือก **Connect to a Redis Stack database** หรือ **Connect to a Redis database**
3. กรอกข้อมูลการเชื่อมต่อ:

**ตัวเลือกที่ 1: Direct Connection to Node**
```
Host: redis-node-1
Port: 6379
Username: admin
Password: admin
```

**ตัวเลือกที่ 2: Connection via HAProxy (แนะนำ)**
```
Host: redis-proxy
Port: 6379
Username: admin
Password: admin
```

### ขั้นตอนที่ 3: ทดสอบการเชื่อมต่อ

- คลิก **Test Connection** เพื่อตรวจสอบ
- คลิก **Add Redis Database** เพื่อบันทึก

## สถาปัตยกรรม

```
┌─────────────────────────────────────────────┐
│         Redis Insight (Port 8001)           │
│              Web Management UI              │
└──────────────────┬──────────────────────────┘
                   │
┌──────────────────▼──────────────────────────┐
│  HAProxy Load Balancer (Port 6379, 7001-7006)
├──────────────────┬──────────────────────────┤
│     Master 1     │   Master 2      Master 3 │
│     (6379)       │   (6379)        (6379)   │
│        │         │      │             │     │
│     Slave 1      │   Slave 2      Slave 3   │
└─────────────────────────────────────────────┘
```

## การยืนยัตว์ (Authentication)

### Default User
- Username: `default`
- Password: ค่าจาก `REDISCLI_AUTH_PASSWORD` ใน `.env`

### Custom User
- Username: ค่าจาก `REDISCLI_AUTH_USERNAME` ใน `.env`
- Password: ค่าจาก `REDISCLI_AUTH_PASSWORD` ใน `.env`

สามารถใช้ทั้งสองอย่างได้เนื่องจากทั้งสองได้รับการตั้งค่าในไฟล์ ACL

## ตัวอย่างการใช้งาน

### ดึงข้อมูล Cluster
```bash
export REDISCLI_AUTH='admin'
redis-cli -h redis-proxy -p 6379 cluster info
```

### SET/GET Operations
```bash
export REDISCLI_AUTH='admin'
redis-cli -h redis-proxy -p 6379 SET mykey "Hello Redis"
redis-cli -h redis-proxy -p 6379 GET mykey
```

### Monitor Commands
```bash
export REDISCLI_AUTH='admin'
redis-cli -h redis-proxy -p 6379 MONITOR
```

## การแก้ไขปัญหา

### ข้อผิดพลาด: "NOAUTH Authentication required"
- ตรวจสอบว่า `.env` มี `REDISCLI_AUTH_USERNAME` และ `REDISCLI_AUTH_PASSWORD`
- Restart cluster: `./stop-cluster.sh && ./start-cluster.sh`

### ข้อผิดพลาด: "Connection refused"
- ตรวจสอบว่า containers กำลังทำงาน: `docker-compose ps`
- ดูข้อมูล logs: `docker-compose logs redis-node-1`

### ข้อผิดพลาด: "cluster_state:fail"
- Cluster อาจยังกำลัง initialize รอสัก 10 วินาที
- ลอง `./test-cluster.sh` อีกครั้ง

### Redis Insight ไม่สามารถเชื่อมต่อ
- ตรวจสอบ port 8001 ว่ามี expose หรือไม่: `docker-compose ps redis-insight`
- ลองใช้ `127.0.0.1` แทน `localhost`

## ข้อควรระวัง

⚠️ อย่า commit ไฟล์ `.env` - มี credentials อยู่ในนั้น
- ตรวจสอบให้แน่ใจว่า `.gitignore` มี `.env`

⚠️ ใช้ password ที่แข็งแกร่ง ในสภาพแวดล้อมโปรดักชั่น
- อย่าใช้ `admin` ในสภาพแวดล้อมโปรดักชั่น

⚠️ ต้องเปิด ports ที่จำเป็น
- ตรวจสอบให้แน่ใจว่า ports เหล่านี้พร้อม:
  - 6379 (Redis)
  - 7001-7006 (HAProxy)
  - 8001 (Redis Insight)
  - 8404 (HAProxy Stats)

## Services และ Ports

| Service | Port | วัตถุประสงค์ |
|---------|------|-----------|
| Redis Nodes 1-6 | 6379 | Redis Cluster Nodes |
| HAProxy | 7001-7006 | Load Balancer (forward จาก 9001-9006) |
| HAProxy Stats | 8404 | HAProxy Statistics Dashboard |
| Redis Insight | 8001 | Web-based Redis Management UI |

## ลิงก์ที่มีประโยชน์

- Redis Cluster Documentation: https://redis.io/docs/management/clustering/
- Redis CLI: https://redis.io/docs/connect/cli/
- HAProxy: http://www.haproxy.org/
- Redis Insight: https://redis.com/redis-enterprise/redis-insight/

## ใบอนุญาต

MIT

---

สร้างเมื่อ: 2025-12-02
เวอร์ชัน: 1.0.0
