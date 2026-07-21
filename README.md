# Handoff: ระบบเงินเดือน HR — NNY Materials (HR Payroll System)

## Overview
ระบบคำนวณค่าตอบแทนพนักงานรายเดือน สำหรับ บริษัท เอ็นเอ็นวาย แมททีเรียลส์ จำกัด (โรงงานคอนกรีตผสมเสร็จ) รองรับพนักงาน 7 กลุ่มงานที่มีสูตรคำนวณค่าตอบแทนต่างกัน พร้อมระบบสิทธิ์ผู้ใช้งานแบบ Maker–Checker–Approver (คนกรอก / คนตรวจสอบ / คนอนุมัติ) ตามหลัก internal control ทั่วไปของงานบัญชี/การเงิน

เป้าหมายของระบบ: แทนที่การกรอกค่าเที่ยว/ยอดขาย/ค่าแรงในไฟล์ Excel รายเดือน ด้วยเว็บแอปที่คำนวณอัตโนมัติ มีการอนุมัติเป็นขั้นตอน และเก็บประวัติย้อนหลังได้

## About the Design Files
ไฟล์ `HR Payroll.dc.html` ที่แนบมาเป็น **ต้นแบบการออกแบบ (design reference)** เขียนด้วย HTML/inline-JS framework เฉพาะของเครื่องมือออกแบบ — **ไม่ใช่โค้ด production ให้ก๊อปวางตรงๆ** งานของทีมพัฒนาคือนำ UI, logic การคำนวณ, และ flow ที่ออกแบบไว้นี้ไปสร้างใหม่ในระบบ/เฟรมเวิร์กจริงของบริษัท (React, Vue, .NET, Laravel ฯลฯ) พร้อมต่อฐานข้อมูลกลางและระบบ authentication ที่ปลอดภัยจริง

ปัจจุบันดีพลอยทดลองใช้งานที่ (ข้อมูลเก็บใน localStorage ของเบราว์เซอร์ ไม่ใช่ฐานข้อมูลกลาง):
https://hr-nny-materials-cd-70fab966f0.netlify.app

## Fidelity
**High-fidelity** — สี, ระยะห่าง, ฟอนต์, และ interaction ทั้งหมดคือของจริงที่ต้องการ ไม่ใช่ wireframe ทีมพัฒนาควร recreate UI ให้ใกล้เคียงต้นแบบมากที่สุด โดยใช้ component library/design system ของโปรเจกต์จริง (ถ้ามี) หรือสร้างตามที่ระบุด้านล่างถ้ายังไม่มีระบบดีไซน์

## ⚠️ สิ่งสำคัญที่สุด: ต้องแทนที่ก่อนใช้งานจริง
1. **Authentication** — ในต้นแบบ user/pass คือค่า hardcode ในโค้ด (`admin/nny12345`, `manager/nny12345`, `maker/maker12345`) **ต้องเปลี่ยนเป็นระบบล็อกอินจริง**: เก็บ user ในฐานข้อมูล, เข้ารหัสรหัสผ่าน (bcrypt/argon2), ออก session/JWT, มี rate-limiting กันการเดารหัส
2. **Data persistence** — ต้นแบบเก็บทุกอย่างใน `localStorage` ของเบราว์เซอร์ ต้องแทนที่ด้วย backend API + database ตาม schema ด้านล่าง
3. **Authorization ฝั่ง server** — สิทธิ์ maker/manager/admin ต้องตรวจสอบที่ backend ด้วย (ไม่ใช่แค่ซ่อนปุ่มฝั่ง frontend เหมือนต้นแบบ) มิฉะนั้น manager สามารถเรียก API แก้ไขข้อมูลตรงๆ ได้

---

## User Roles (Maker / Checker / Approver)

| Role | Username (demo) | สิทธิ์ |
|---|---|---|
| **admin** | admin / nny12345 | เพิ่ม/แก้ไขพนักงาน, กรอกข้อมูล, ตรวจสอบ (verify), อนุมัติ (approve), นำเข้า/ส่งออกไฟล์ |
| **manager** | manager / nny12345 | ดูข้อมูลอย่างเดียว + ตรวจสอบ (verify) เท่านั้น — แก้ไข/กรอกข้อมูลไม่ได้ |
| **maker** | maker / maker12345 | เพิ่มพนักงานใหม่ + กรอก/แก้ไขข้อมูลรายวันเท่านั้น — ตรวจสอบ/อนุมัติไม่ได้ |

สถานะของแต่ละ pay record (ต่อพนักงานต่องวด) ไหลเป็นลำดับ:
`ร่าง / รอตรวจสอบ` → (maker กด "บันทึก") → `รอตรวจสอบ` → (manager/admin กด "ตรวจสอบ") → `ผ่านการตรวจสอบ` → (admin กด "อนุมัติ") → `อนุมัติ`

---

## Screens / Views

### 1. Login
- พื้นหลังเข้ม (`#0f172a`), การ์ดล็อกอินตรงกลาง (`#1e293b`, border-radius 16px, box-shadow เข้ม)
- โลโก้กลม/สี่เหลี่ยมมน 58×58px สีน้ำเงิน `#2563eb` ตัวอักษร "NNY"
- ฟอร์ม: ชื่อผู้ใช้ + รหัสผ่าน (type=password) + ปุ่ม "เข้าสู่ระบบ" (เต็มความกว้าง, พื้นน้ำเงิน)
- แสดง error message สีแดงถ้า login ผิด

### 2. Roster (หน้ารายชื่อพนักงาน — หน้าแรกหลังล็อกอิน)
- Header บนสุด sticky: โลโก้ + ชื่อระบบ, ตัวเลือกงวดเดือน (ปุ่ม ‹ › สลับงวด), badge บทบาทผู้ใช้, ปุ่มออกจากระบบ
- แถบค้นหา + ปุ่ม "+ เพิ่มพนักงาน" (เฉพาะ admin/maker) + ปุ่มนำเข้า Excel + ปุ่มส่งออกสรุป Excel/PDF
- **4 stat cards**: จำนวนพนักงานทั้งหมด, ยอดค่าตอบแทนรวม, รวมเที่ยววิ่ง, จำนวนรอตรวจสอบ
- **แท็บกรองตามกลุ่มงาน**: ทั้งหมด / รถมิกซ์ / รถโม่เสริม / เทรลเลอร์ / รถน้ำ / Loader / พนักงานขาย / พนักงาน — แต่ละแท็บมีตัวเลขจำนวนคน
- **ตารางพนักงาน**: อวาตาร์ตัวย่อชื่อ + ชื่อเต็ม + รหัส/ทะเบียน, badge กลุ่มงาน, ผลงาน (เที่ยว/คิว/วัน), รายได้รวม, ยอดหัก, ค่าตอบแทนสุทธิ, badge สถานะ — คลิกทั้งแถวเพื่อเข้าหน้ารายละเอียด

### 3. Employee Detail (หน้ารายละเอียด + กรอกข้อมูล)
โครงสร้าง 2 คอลัมน์: ซ้าย 1.55fr (ฟอร์มกรอกข้อมูล) / ขวา 1fr (สรุปผล, sticky)

**ส่วนหัว**: อวาตาร์ + ชื่อ + รหัส/badge กลุ่มงาน/badge สถานะ, ตัวแก้ไขช่วงวันที่งวด (start/end DD/MM), ปุ่ม แก้ไขข้อมูล/บันทึก/ตรวจสอบ/อนุมัติ/พิมพ์สลิป (ตามสิทธิ์)

**ฟอร์มกรอกข้อมูลรายวัน — ต่างกันตามกลุ่มงาน** (ดูรายละเอียดสูตรด้านล่าง) แต่ละกลุ่มมีตารางแถวต่อวันตลอดงวด (auto-scroll, max-height 280px) พร้อมแถวสรุปยอดรวมด้านล่าง

**ส่วนรายการหัก** (เฉพาะกลุ่มคนขับ: มิกซ์/รถโม่เสริม/เทรลเลอร์/รถน้ำ): เบิกล่วงหน้า, ประกันสังคม, หักค่าดูแลรถ, อื่นๆ

**คอลัมน์ขวา — สรุปผล**: ตัวเลขค่าตอบแทนสุทธิใหญ่ (font mono), % เปลี่ยนแปลงเทียบงวดก่อน, รายได้รวม/หักรวม, แถบกราฟสัดส่วนรายได้ (stacked bar) พร้อม legend, กราฟแท่งย้อนหลัง 6 งวด

### 4. Add/Edit Employee Modal
- Overlay มืด + การ์ดตรงกลาง (500px)
- ฟิลด์: ชื่อ-สกุล*, รหัสพนักงาน, ตำแหน่ง/แผนก, ปุ่มเลือกกลุ่มงาน (7 ปุ่ม toggle), เลขรถ+ทะเบียน (เฉพาะกลุ่มยานพาหนะ)
- ปุ่ม ยกเลิก / เพิ่มพนักงาน (หรือ บันทึกการแก้ไข)

### 5. Printed Payslip (เปิดหน้าต่างใหม่)
เอกสารขนาด ~380px width, แสดงชื่อบริษัท, งวด, ชื่อ/รหัส/ตำแหน่งพนักงาน, ตารางรายการรายได้, รายได้รวม/หัก/สุทธิ, ช่องเซ็นผู้อนุมัติ — trigger `window.print()`

### 6. Summary Export (Excel/PDF)
รายงานสรุปทุกคนในงวดที่เลือก: รหัส, ชื่อ, กลุ่มงาน, รายได้รวม, หัก, สุทธิ, สถานะ — export เป็น `.xls` (HTML table + MIME `application/vnd.ms-excel`) หรือเปิด print dialog สำหรับ PDF

---

## Compensation Formulas by Employee Group

ทุกกลุ่มมี **อัตรา (rate) เป็นค่าต่อพนักงานแต่ละคน** (ไม่ใช่ค่าคงที่ระบบ) แก้ไขได้อิสระต่อคน

### 1. รถมิกซ์ (mixer) และ รถโม่เสริม (auxmixer) — สูตรเดียวกัน
ต่อวัน บันทึก: จำนวนเที่ยวก่อน 8:00, จำนวนเที่ยว 8:00–17:00, จำนวนเที่ยวหลัง 17:00, จำนวนคิว (ม³)
```
รายได้ = (เที่ยวก่อน8:00 × earlyRate) + (เที่ยว8-17 × dayRate) + (เที่ยวหลัง17:00 × nightRate) + ค่าดูแลรถ(คงที่/งวด)
ค่าเริ่มต้น: earlyRate=100฿, dayRate=80฿, nightRate=100฿, ค่าดูแลรถ=1000฿/งวด
หัก = เบิกล่วงหน้า + ประกันสังคม + หักค่าดูแลรถ(กรณีทำเสียหาย) + อื่นๆ
สุทธิ = รายได้ - หัก
```
หมายเหตุ: คอลัมน์ "คิว"บันทึกไว้แต่ปัจจุบันไม่คูณเข้าสูตร (ไม่มีอัตราค่าคิวกำหนดชัดเจน — ควรยืนยันกับ HR ก่อนเปิดใช้งานจริง)

### 2. เทรลเลอร์ (trailer)
ต่อวัน บันทึก: จำนวนเที่ยว, น้ำหนักบรรทุก (ตัน)
```
รายได้ = (จำนวนเที่ยว × trailerRate) + ค่าดูแลรถ(คงที่/งวด)
ค่าเริ่มต้น: trailerRate=200฿/เที่ยว, ค่าดูแลรถ=1000฿/งวด
หัก = เหมือนกลุ่มรถมิกซ์
```
น้ำหนัก (ตัน) บันทึกไว้เพื่อรายงาน ไม่ใช้ในสูตรคำนวณ

### 3. รถน้ำ (water)
ต่อวัน บันทึก: จำนวนเที่ยว, ปริมาณน้ำ (ถัง/ลิตร)
```
รายได้ = (จำนวนเที่ยว × waterRate) + ค่าดูแลรถ(คงที่/งวด)
ค่าเริ่มต้น: waterRate=45฿/เที่ยว, ค่าดูแลรถ=1000฿/งวด
หัก = เหมือนกลุ่มรถมิกซ์
```

### 4. Loader
**ใช้สูตรเดียวกับกลุ่ม "พนักงาน"** (ไม่ใช่แบบคนขับรถ — ไม่มีค่าดูแลรถ/หัก) ดูสูตรข้อ 6

### 5. พนักงานขาย (sales)
ไม่มีเงินเดือนฐาน — รายได้ทั้งหมดมาจากค่าคอมมิชชั่นตามรายการขาย ผูกกับ ลูกค้า + หน่วยงาน/โครงการ (แยกฟิลด์กัน) + รหัสสินค้า + จำนวนคิว + ประเภท (เครดิต/เงินสด/สินค้าอื่นๆ)
```
คอมฯ เครดิต = Σ(คิว ที่ kind=credit) × creditRate
คอมฯ เงินสด = Σ(คิว ที่ kind=cash) × cashRate
คอมฯ สินค้าอื่นๆ = Σ(คิว ที่ productType=other) × otherRate
รายได้รวม = คอมฯ เครดิต + คอมฯ เงินสด + คอมฯ สินค้าอื่นๆ
ค่าเริ่มต้น: creditRate=5฿/คิว, cashRate=7฿/คิว, otherRate=10฿/หน่วย
ไม่มีรายการหัก (deductions) สำหรับกลุ่มนี้
```
รายการขายเป็น list ที่เพิ่ม/ลบ/แก้ไขได้อิสระ (ไม่ผูกกับวันที่ในงวด — ผูกกับงวดเท่านั้น)

### 6. พนักงาน (worker) — และ Loader
ต่อวัน บันทึก: สถานะมา/ขาด, จำนวนผลผลิต (ชิ้น), ชั่วโมง OT
```
ค่าแรงรายวัน = (จำนวนวันที่มาทำงาน) × dailyWage
ค่าผลิต = (ผลผลิตรวมทั้งงวด) × ratePerUnit
ค่าล่วงเวลา = (OT รวมทั้งงวด) × otRate
รายได้รวม = ค่าแรงรายวัน + ค่าผลิต + ค่าล่วงเวลา
ค่าเริ่มต้น: dailyWage=350฿/วัน, ratePerUnit=2.5฿/ชิ้น, otRate=70฿/ชม.
ไม่มีรายการหัก (deductions) สำหรับกลุ่มนี้
```

---

## Data Schema (แนะนำสำหรับฐานข้อมูลกลาง)

```
users
  id, username, password_hash, role (enum: admin|manager|maker), created_at

employees
  id, employee_code, name, role_title, employee_group
    (enum: mixer|auxmixer|trailer|water|loader|sales|worker),
  vehicle_no NULL, license_plate NULL,
  -- rate fields (nullable, only relevant ones populated per group):
  early_rate, day_rate, night_rate,      -- mixer/auxmixer
  trailer_rate,                          -- trailer
  water_rate,                            -- water
  credit_rate, cash_rate, other_rate,    -- sales
  daily_wage, rate_per_unit, ot_rate,    -- worker/loader
  cleaning_fee,                          -- vehicle groups, per-period base
  created_at, updated_at, active (bool)

pay_periods
  id, period_key (e.g. "2569-06"), name, period_start (date), period_end (date)

pay_records                              -- one per employee per period
  id, employee_id (FK), period_id (FK),
  status (enum: draft|pending_review|reviewed|approved),
  advance, sso, care_deduction, other_deduction,
  reviewed_by (FK users) NULL, reviewed_at NULL,
  approved_by (FK users) NULL, approved_at NULL,
  created_at, updated_at

daily_entries                            -- vehicle groups + worker/loader
  id, pay_record_id (FK), entry_date (date),
  -- vehicle (mixer/auxmixer):
  trips_early, trips_day, trips_night, queue_units,
  -- trailer:
  trips, tonnage,
  -- water:
  trips, volume,
  -- worker/loader:
  present (bool), units_produced, ot_hours

sales_line_items                         -- sales group only
  id, pay_record_id (FK),
  customer_name, site_name, product_code,
  quantity, kind (enum: credit|cash), product_type (enum: concrete|other)
```

**Calculated fields ที่ backend ต้องคำนวณ** (ไม่ควรเก็บเป็น stored value ให้คำนวณสดจาก daily_entries/sales_line_items + rates ทุกครั้งที่แสดงผล เพื่อไม่ให้ข้อมูลไม่ตรงกันเมื่อแก้ rate ย้อนหลัง): `gross_pay`, `total_deductions`, `net_pay` ตามสูตรข้างบนของแต่ละกลุ่ม

---

## Interactions & Behavior
- ทุก input ตัวเลขอัปเดตยอดสุทธิ "สด" (ไม่ต้องกดปุ่มคำนวณ) — ทำ debounce ที่ backend เวลา autosave ถ้าจะทำ
- Readonly state: เมื่อ role = manager หรือดูข้อมูลที่ status = approved แล้ว (ควรพิจารณาว่าจะ lock ข้อมูลหลังอนุมัติ ทีมพัฒนาตัดสินใจตามนโยบายบริษัท)
- Toast แจ้งเตือนมุมล่างกลาง หายเองใน ~2.6-2.8 วินาที หลังการบันทึก/ตรวจสอบ/อนุมัติ/เพิ่มพนักงาน
- การสลับงวด (‹ ›) โหลดชุดข้อมูลของงวดนั้น ถ้ายังไม่มีข้อมูล สร้างแถวว่างตามช่วงวันที่ของงวด
- แก้ไขวันเริ่ม/สิ้นสุดงวด → regenerate ตารางวันที่ใหม่ โดย "เก็บข้อมูลเดิมไว้" ถ้าวันที่ตรงกับของเดิม (match by date string)
- นำเข้า Excel: อ่านไฟล์ .xlsx รูปแบบเดิมของบริษัท (แต่ละ sheet = 1 คนขับ, จับคู่อัตโนมัติด้วยเลขรถที่ cell A3), เติมข้อมูลเที่ยว/กะกลางวัน-กลางคืนลงในงวดปัจจุบัน

## State Management (แนวคิดจากต้นแบบ — ไปปรับใช้กับ state library จริง)
- Current view: `login | roster | detail`
- Current user role: `admin | manager | maker | null`
- Active period key + editable start/end date strings
- Employees list (each with per-period `payData` keyed by period key)
- Roster filter (by group) + search query
- Selected employee id (for detail view)
- Modal state (add/edit employee) — null when closed
- Toast message string — auto-clears

## Design Tokens

**Colors**
- Background: `#eef2f7` (page), `#ffffff` (cards)
- Text: `#1e293b` (primary), `#64748b` (secondary), `#94a3b8` (tertiary/labels)
- Primary/accent: `#2563eb` (blue), hover `#1d4ed8`
- Success/income: `#16a34a` green
- Danger/deduction: `#dc2626` red
- Warning/pending: `#b45309` on `#fef3c7`
- Borders: `#e2e8f0`
- Group badge colors: มิกซ์ `#dbeafe`/`#1d4ed8`, รถโม่เสริม `#bfdbfe`/`#1e40af`, เทรลเลอร์ `#e0e7ff`/`#4338ca`, รถน้ำ `#e0f2fe`/`#0284c7`, Loader `#fef9c3`/`#854d0e`, พนักงานขาย `#cffafe`/`#0e7490`, พนักงาน `#ede9fe`/`#6d28d9`

**Typography**
- Font: `IBM Plex Sans Thai` (UI text), `IBM Plex Mono` (ตัวเลข/เงิน/วันที่) — Google Fonts, weights 400/500/600/700
- Sizes: 33px (ตัวเลขสุทธิใหญ่), 21-23px (ชื่อ), 14-15px (body/input), 12-13px (labels/secondary), 10-11px (micro labels)

**Radius / Shadow**
- Card radius: 14px, buttons/inputs 9-10px, badges/pills fully rounded (20px)
- Card shadow: `0 1px 3px rgba(15,23,42,.04)` (subtle), modal `0 24px 64px rgba(15,23,42,.28)`

**Spacing**
- Page padding: 22-30px, card padding: 20-22px, gaps: 8-18px depending on density

## Assets
ไม่มี asset ภายนอก (รูปภาพ/โลโก้) — โลโก้เป็นตัวอักษร "NNY" ในกล่องสีพื้น ไม่มีไฟล์ภาพให้จัดเตรียม

## Files in This Bundle
- `HR Payroll.dc.html` — ไฟล์ต้นแบบเต็มระบบ (login, roster, detail, modal, print, export) เขียนด้วย inline-styled template + JS logic class เฉพาะเครื่องมือออกแบบ ใช้เป็นข้อมูลอ้างอิงโครงสร้างหน้าจอ, สูตรคำนวณ (ดูใน logic class), และ copy ข้อความภาษาไทยทั้งหมด — **ไม่ต้อง deploy ไฟล์นี้ตรงๆ ในระบบ production**
