# SINDEL: Shadow Intelligence Network & Data Extraction Laboratory

![SINDEL](app/public/images/sindel.png)
![SINDEL Dashboard](app/public/image2.jpeg)

**SINDEL Shadow Intelligence Network & Data Extraction Laboratory** is a purpose-built Capture The Flag (CTF) environment designed by **Nana Sei Anyemedu** for **Hive Consult**. Unlike general-purpose penetration test labs, SINDEL focuses exclusively on **Insecure Direct Object Reference (IDOR)** vulnerabilities, covering all 10 recognised IDOR attack categories across 18 distinct endpoints.

The lab demonstrates that IDOR is not a single vulnerability type but an entire family of access control failures. An attacker who understands IDOR across all identifier types can compromise virtually any web application that stores user-specific data.

All 18 flags were captured across all difficulty levels. The most technically demanding findings are the hashed identifier IDORs and the token-based IDORs, which require understanding of cryptographic weaknesses and enumeration techniques beyond simple integer incrementing.

---

## Technical Stack

- **Backend:** Node.js with Express.js
- **Database:** SQLite3
- **Authentication:** JWT (JSON Web Tokens) with Cookie storage
- **Containerization:** Docker & Docker Compose
- **Frontend:** Vanilla JS, CSS3, HTML5

---

## Vulnerability Coverage

SINDEL is designed to simulate a real-world intelligence agency's web portal, where different types of identifiers are used to access sensitive agent dossiers, mission briefs, and intel reports.

The laboratory covers 10 primary IDOR categories:

| ID | Category | Description |
|---|---|---|
| **I1** | **Numeric ID** | Sequential integer identifiers (e.g., `/api/agents/1`). |
| **I2** | **UUID** | Universally Unique Identifiers that are leaked or guessable. |
| **I3** | **PII-based (Phone)** | Using phone numbers as direct lookups without ownership validation. |
| **I4** | **PII-based (Email)** | Using email addresses as direct lookups. |
| **I5** | **Username** | Using usernames in the URL path to access private data. |
| **I6** | **Slug-based** | Human-readable URL slugs (e.g., `/api/intel/operation-nightfall`). |
| **I7** | **Composite IDOR** | Bypassing access controls by combining multiple predictable fields (e.g., Name + DOB). |
| **I8** | **File Path** | Direct reference to file system paths (e.g., `/api/files/read?path=...`). |
| **I9** | **Encoded Ref** | Identifiers obfuscated with Base64, Hex, or URL encoding. |
| **I10** | **Hashed Ref** | Identifiers protected by weak or enumerable hashes (MD5, SHA1). |
| **I11** | **Token-based** | Sequential or predictable tokens for Magic Links and Password Resets. |

---

## Getting Started

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)

### Installation & Deployment

1. Clone the repository:
   ```bash
   cd sindel-ctf
   ```

2. Start the laboratory environment:
   ```bash
   docker-compose up -d
   ```

3. Access the application:
   Open your browser and navigate to `http://localhost:8888`.

---

## How to Play

1. **Login:** Start by logging in with the default recruit credentials (found in the setup logic or by enumerating the system).
2. **Reconnaissance:** Use the dashboard to understand how your own data is retrieved.
3. **Analyze Identifiers:** Pay close attention to API calls in the Network tab of your browser's Developer Tools. Look for IDs, UUIDs, Slugs, and Encoded strings.
4. **Manipulate:** Attempt to access other agents' data by modifying the identifiers.
5. **Capture Flags:** Each successful IDOR exploit will reveal a flag in the format `HIVE{...}`.

---

## Disclaimer

SINDEL is intended for educational and ethical security testing purposes only. Do not attempt to use the techniques learned here on any system you do not have explicit permission to test.

**Designed by:** Nana Sei Anyemedu  
**Organization:** Hive Consult
