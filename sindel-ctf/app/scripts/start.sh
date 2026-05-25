#!/bin/bash

# Write flags to individual files at runtime — never in source code
mkdir -p /app/flags /app/files/classified /app/files/agents /etc/sindel

# API flags — each in its own file, read by server.js at runtime
echo "HIVE{num3r1c_1d_1d0r_4g3nt_d4t4_l34k3d}"           > /app/flags/i1
echo "HIVE{uu1d_m1ss10n_1d0r_cl4ss1f13d_3xp0s3d}"         > /app/flags/i2
echo "HIVE{ph0n3_num_1d0r_4g3nt_l0c4t3d}"                  > /app/flags/i3
echo "HIVE{3m41l_1d0r_0p3r4t1v3_pr0f1l3_3xp0s3d}"         > /app/flags/i4
echo "HIVE{us3rn4m3_1d0r_s3cr3t_n0t3_r34d}"                > /app/flags/i5
echo "HIVE{slvg_1d0r_1nt3l_r3p0rt_cl4ss1f13d}"             > /app/flags/i6
echo "HIVE{c0mp0s1t3_1d0r_ph0n3_d0b_byp4ss}"               > /app/flags/i7a
echo "HIVE{c0mp0s1t3_1d0r_3m41l_c0d3_byp4ss}"              > /app/flags/i7b
echo "HIVE{c0mp0s1t3_1d0r_n4m3_b1rth_byp4ss}"              > /app/flags/i7c
echo "HIVE{f1l3_p4th_1d0r_cl4ss1f13d_f1l3_r34d}"           > /app/flags/i8
echo "HIVE{b4s364_1d0r_3nc0d3d_r3f_byp4ss}"                > /app/flags/i9a
echo "HIVE{h3x_1d0r_3nc0d3d_r3f_byp4ss}"                   > /app/flags/i9b
echo "HIVE{url_3nc0d3d_1d0r_r3f_byp4ss}"                   > /app/flags/i9c
echo "HIVE{md5_h4sh_1d0r_3m41l_l00kup_byp4ss}"             > /app/flags/i10a
echo "HIVE{sh41_h4sh_1d0r_us3rn4m3_l00kup_byp4ss}"         > /app/flags/i10b
echo "HIVE{m4g1c_l1nk_1d0r_t0k3n_s3qu3nt14l}"              > /app/flags/i11a
echo "HIVE{r3s3t_t0k3n_1d0r_b4s364_byp4ss}"                > /app/flags/i11b
echo "HIVE{qr_t0k3n_1d0r_w34k_c0d3_byp4ss}"                > /app/flags/i11c
chmod 600 /app/flags/*

# File-based flags — inside agent files (discovered via file path IDOR)
cat > /app/files/agents/agent_001.txt << 'F'
AGENT DOSSIER — CLASSIFIED
Name: Kira Nakamura  Codename: PHANTOM  Clearance: OMEGA
Bank Account: GH-ACC-229-88774411  Passphrase: midnight-lotus-7749
FLAG: HIVE{f1l3_p4th_1d0r_4g3nt_d0ss13r_l34k3d}
F

cat > /app/files/agents/agent_002.txt << 'F'
AGENT DOSSIER — CLASSIFIED
Name: Marcus Osei  Codename: WRAITH  Clearance: SIGMA
Safe House: 44 Shadow Lane, Accra  Passphrase: iron-serpent-3301
FLAG: HIVE{f1l3_p4th_1d0r_wr41th_d0ss13r_l34k3d}
F

cat > /app/files/classified/mission_alpha.txt << 'F'
OPERATION ALPHA — EYES ONLY
Target: HVA  Location: Grid 77-Alpha  Handler: Director Mawuli
FLAG: HIVE{f1l3_p4th_1d0r_m1ss10n_4lph4_3xp0s3d}
F

cat > /app/files/classified/shadow_config.txt << 'F'
SINDEL INTERNAL CONFIG
JWT_SECRET=sindel_shadow_ops_2025
FLAG: HIVE{f1l3_p4th_1d0r_c0nf1g_3xp0s3d}
F

chmod -R 644 /app/files

cat > /etc/sindel/ops.key << 'K'
SINDEL Shadow Network Key
JWT_SECRET=sindel_shadow_ops_2025
Property of: Hive Consult, Ghana
K

echo "HIVE{r00t_pr1v3sc_s1nd3l_c0mpr0m1s3d}" > /root/root.txt
chmod 600 /root/root.txt

node /app/setup.js
exec node /app/server.js
