--------------------------------------------------------
--  DDL for Package Body OE_ORDER_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_ORDER_PVT_W" as
  /* $Header: OERVORDB.pls 120.0 2005/05/31 23:16:57 appldev noship $ */
  rosetta_g_mistake_date date := to_date('01/01/+4713', 'MM/DD/SYYYY');
  rosetta_g_miss_date date := to_date('01/01/-4712', 'MM/DD/SYYYY');

  l_fname varchar2(240);



  -- this is to workaround the JDBC bug regarding IN DATE of value GMiss
  function rosetta_g_miss_date_in_map(d date) return date as
  begin
    if d = rosetta_g_mistake_date then return fnd_api.g_miss_date; end if;
    return d;
  end;

  function rosetta_g_miss_num_map(n number) return number as
    a number := fnd_api.g_miss_num;
    b number := 0-1962.0724;
  begin
    if n=a then return b; end if;
    if n=b then return a; end if;
    return n;
  end;

  procedure header(p_init_msg_list  VARCHAR2
    , p_validation_level  NUMBER
    , p2_a0  NUMBER
    , p2_a1  NUMBER
    , p2_a2  NUMBER
    , p2_a3  NUMBER
    , p2_a4  NUMBER
    , p2_a5  NUMBER
    , p2_a6  NUMBER
    , p2_a7  NUMBER
    , p2_a8  NUMBER
    , p2_a9  NUMBER
    , p2_a10  VARCHAR2
    , p2_a11  NUMBER
    , p2_a12  NUMBER
    , p2_a13  VARCHAR2
    , p2_a14  VARCHAR2
    , p2_a15  NUMBER
    , p3_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p3_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p3_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p3_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a0 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a1 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a2 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a3 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a4 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a5 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a6 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a7 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a8 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a9 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a10 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a11 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a12 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a13 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a14 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a15 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a16 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a17 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a18 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a19 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a20 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a21 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a22 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a23 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a24 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a25 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a26 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a27 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a28 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a29 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a30 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a31 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a32 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a33 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a34 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a35 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a36 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a37 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a38 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a39 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a40 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a41 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a42 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a43 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a44 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a45 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a46 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a47 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a48 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a49 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a50 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a51 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a52 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a53 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a54 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a55 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a56 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a57 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a58 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a59 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a60 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a61 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a62 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a63 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a64 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a65 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a66 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a67 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a68 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a69 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a70 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a71 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a72 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a73 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a74 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a75 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a76 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a77 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a78 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a79 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a80 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a81 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a82 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a83 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a84 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a85 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a86 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a87 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a88 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a89 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a90 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a91 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a92 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a93 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a94 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a95 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a96 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a97 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a98 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a99 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a100 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a101 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a102 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a103 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a104 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a105 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a106 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a107 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a108 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a109 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a110 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a111 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a112 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a113 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a114 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a115 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a116 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a117 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a118 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a119 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a120 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a121 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a122 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a123 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a124 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a125 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a126 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a127 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a128 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a129 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a130 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a131 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a132 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a133 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a134 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a135 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a136 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a137 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a138 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a139 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a140 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a141 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a142 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a143 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a144 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a145 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a146 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a147 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a148 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a149 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a150 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a151 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a152 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a153 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a154 in out NOCOPY /* file.sql.39 change */  DATE
    , p4_a155 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a156 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a157 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a158 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a159 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a160 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a161 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a162 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a163 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a164 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a165 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a166 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a167 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a168 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a169 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a170 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a171 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a172 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a173 in out NOCOPY /* file.sql.39 change */  NUMBER
    , p4_a174 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a175 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , p4_a176 in out NOCOPY /* file.sql.39 change */  VARCHAR2
    , x_return_status out NOCOPY /* file.sql.39 change */  VARCHAR2
  )

  as
    ddp_control_rec oe_globals.control_rec_type;
    ddp_x_header_rec oe_order_pub.header_rec_type;
    ddp_x_old_header_rec oe_order_pub.header_rec_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any


    if p2_a0 is null
      then ddp_control_rec.controlled_operation := null;
    elsif p2_a0 = 0
      then ddp_control_rec.controlled_operation := false;
    else ddp_control_rec.controlled_operation := true;
    end if;
    if p2_a1 is null
      then ddp_control_rec.private_call := null;
    elsif p2_a1 = 0
      then ddp_control_rec.private_call := false;
    else ddp_control_rec.private_call := true;
    end if;
    if p2_a2 is null
      then ddp_control_rec.check_security := null;
    elsif p2_a2 = 0
      then ddp_control_rec.check_security := false;
    else ddp_control_rec.check_security := true;
    end if;
    if p2_a3 is null
      then ddp_control_rec.clear_dependents := null;
    elsif p2_a3 = 0
      then ddp_control_rec.clear_dependents := false;
    else ddp_control_rec.clear_dependents := true;
    end if;
    if p2_a4 is null
      then ddp_control_rec.default_attributes := null;
    elsif p2_a4 = 0
      then ddp_control_rec.default_attributes := false;
    else ddp_control_rec.default_attributes := true;
    end if;
    if p2_a5 is null
      then ddp_control_rec.change_attributes := null;
    elsif p2_a5 = 0
      then ddp_control_rec.change_attributes := false;
    else ddp_control_rec.change_attributes := true;
    end if;
    if p2_a6 is null
      then ddp_control_rec.validate_entity := null;
    elsif p2_a6 = 0
      then ddp_control_rec.validate_entity := false;
    else ddp_control_rec.validate_entity := true;
    end if;
    if p2_a7 is null
      then ddp_control_rec.write_to_db := null;
    elsif p2_a7 = 0
      then ddp_control_rec.write_to_db := false;
    else ddp_control_rec.write_to_db := true;
    end if;
    if p2_a8 is null
      then ddp_control_rec.process_partial := null;
    elsif p2_a8 = 0
      then ddp_control_rec.process_partial := false;
    else ddp_control_rec.process_partial := true;
    end if;
    if p2_a9 is null
      then ddp_control_rec.process := null;
    elsif p2_a9 = 0
      then ddp_control_rec.process := false;
    else ddp_control_rec.process := true;
    end if;
    ddp_control_rec.process_entity := p2_a10;
    if p2_a11 is null
      then ddp_control_rec.clear_api_cache := null;
    elsif p2_a11 = 0
      then ddp_control_rec.clear_api_cache := false;
    else ddp_control_rec.clear_api_cache := true;
    end if;
    if p2_a12 is null
      then ddp_control_rec.clear_api_requests := null;
    elsif p2_a12 = 0
      then ddp_control_rec.clear_api_requests := false;
    else ddp_control_rec.clear_api_requests := true;
    end if;
    ddp_control_rec.request_category := p2_a13;
    ddp_control_rec.request_name := p2_a14;
    ddp_control_rec.org_id := rosetta_g_miss_num_map(p2_a15);

    ddp_x_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p3_a0);
    ddp_x_header_rec.agreement_id := rosetta_g_miss_num_map(p3_a1);
    ddp_x_header_rec.attribute1 := p3_a2;
    ddp_x_header_rec.attribute10 := p3_a3;
    ddp_x_header_rec.attribute11 := p3_a4;
    ddp_x_header_rec.attribute12 := p3_a5;
    ddp_x_header_rec.attribute13 := p3_a6;
    ddp_x_header_rec.attribute14 := p3_a7;
    ddp_x_header_rec.attribute15 := p3_a8;
    ddp_x_header_rec.attribute16 := p3_a9;
    ddp_x_header_rec.attribute17 := p3_a10;
    ddp_x_header_rec.attribute18 := p3_a11;
    ddp_x_header_rec.attribute19 := p3_a12;
    ddp_x_header_rec.attribute2 := p3_a13;
    ddp_x_header_rec.attribute20 := p3_a14;
    ddp_x_header_rec.attribute3 := p3_a15;
    ddp_x_header_rec.attribute4 := p3_a16;
    ddp_x_header_rec.attribute5 := p3_a17;
    ddp_x_header_rec.attribute6 := p3_a18;
    ddp_x_header_rec.attribute7 := p3_a19;
    ddp_x_header_rec.attribute8 := p3_a20;
    ddp_x_header_rec.attribute9 := p3_a21;
    ddp_x_header_rec.booked_flag := p3_a22;
    ddp_x_header_rec.cancelled_flag := p3_a23;
    ddp_x_header_rec.context := p3_a24;
    ddp_x_header_rec.conversion_rate := rosetta_g_miss_num_map(p3_a25);
    ddp_x_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p3_a26);
    ddp_x_header_rec.conversion_type_code := p3_a27;
    ddp_x_header_rec.customer_preference_set_code := p3_a28;
    ddp_x_header_rec.created_by := rosetta_g_miss_num_map(p3_a29);
    ddp_x_header_rec.creation_date := rosetta_g_miss_date_in_map(p3_a30);
    ddp_x_header_rec.cust_po_number := p3_a31;
    ddp_x_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p3_a32);
    ddp_x_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p3_a33);
    ddp_x_header_rec.demand_class_code := p3_a34;
    ddp_x_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p3_a35);
    ddp_x_header_rec.expiration_date := rosetta_g_miss_date_in_map(p3_a36);
    ddp_x_header_rec.fob_point_code := p3_a37;
    ddp_x_header_rec.freight_carrier_code := p3_a38;
    ddp_x_header_rec.freight_terms_code := p3_a39;
    ddp_x_header_rec.global_attribute1 := p3_a40;
    ddp_x_header_rec.global_attribute10 := p3_a41;
    ddp_x_header_rec.global_attribute11 := p3_a42;
    ddp_x_header_rec.global_attribute12 := p3_a43;
    ddp_x_header_rec.global_attribute13 := p3_a44;
    ddp_x_header_rec.global_attribute14 := p3_a45;
    ddp_x_header_rec.global_attribute15 := p3_a46;
    ddp_x_header_rec.global_attribute16 := p3_a47;
    ddp_x_header_rec.global_attribute17 := p3_a48;
    ddp_x_header_rec.global_attribute18 := p3_a49;
    ddp_x_header_rec.global_attribute19 := p3_a50;
    ddp_x_header_rec.global_attribute2 := p3_a51;
    ddp_x_header_rec.global_attribute20 := p3_a52;
    ddp_x_header_rec.global_attribute3 := p3_a53;
    ddp_x_header_rec.global_attribute4 := p3_a54;
    ddp_x_header_rec.global_attribute5 := p3_a55;
    ddp_x_header_rec.global_attribute6 := p3_a56;
    ddp_x_header_rec.global_attribute7 := p3_a57;
    ddp_x_header_rec.global_attribute8 := p3_a58;
    ddp_x_header_rec.global_attribute9 := p3_a59;
    ddp_x_header_rec.global_attribute_category := p3_a60;
    ddp_x_header_rec.tp_context := p3_a61;
    ddp_x_header_rec.tp_attribute1 := p3_a62;
    ddp_x_header_rec.tp_attribute2 := p3_a63;
    ddp_x_header_rec.tp_attribute3 := p3_a64;
    ddp_x_header_rec.tp_attribute4 := p3_a65;
    ddp_x_header_rec.tp_attribute5 := p3_a66;
    ddp_x_header_rec.tp_attribute6 := p3_a67;
    ddp_x_header_rec.tp_attribute7 := p3_a68;
    ddp_x_header_rec.tp_attribute8 := p3_a69;
    ddp_x_header_rec.tp_attribute9 := p3_a70;
    ddp_x_header_rec.tp_attribute10 := p3_a71;
    ddp_x_header_rec.tp_attribute11 := p3_a72;
    ddp_x_header_rec.tp_attribute12 := p3_a73;
    ddp_x_header_rec.tp_attribute13 := p3_a74;
    ddp_x_header_rec.tp_attribute14 := p3_a75;
    ddp_x_header_rec.tp_attribute15 := p3_a76;
    ddp_x_header_rec.header_id := rosetta_g_miss_num_map(p3_a77);
    ddp_x_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p3_a78);
    ddp_x_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p3_a79);
    ddp_x_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p3_a80);
    ddp_x_header_rec.last_updated_by := rosetta_g_miss_num_map(p3_a81);
    ddp_x_header_rec.last_update_date := rosetta_g_miss_date_in_map(p3_a82);
    ddp_x_header_rec.last_update_login := rosetta_g_miss_num_map(p3_a83);
    ddp_x_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p3_a84);
    ddp_x_header_rec.open_flag := p3_a85;
    ddp_x_header_rec.order_category_code := p3_a86;
    ddp_x_header_rec.ordered_date := rosetta_g_miss_date_in_map(p3_a87);
    ddp_x_header_rec.order_date_type_code := p3_a88;
    ddp_x_header_rec.order_number := rosetta_g_miss_num_map(p3_a89);
    ddp_x_header_rec.order_source_id := rosetta_g_miss_num_map(p3_a90);
    ddp_x_header_rec.order_type_id := rosetta_g_miss_num_map(p3_a91);
    ddp_x_header_rec.org_id := rosetta_g_miss_num_map(p3_a92);
    ddp_x_header_rec.orig_sys_document_ref := p3_a93;
    ddp_x_header_rec.partial_shipments_allowed := p3_a94;
    ddp_x_header_rec.payment_term_id := rosetta_g_miss_num_map(p3_a95);
    ddp_x_header_rec.price_list_id := rosetta_g_miss_num_map(p3_a96);
    ddp_x_header_rec.price_request_code := p3_a97;
    ddp_x_header_rec.pricing_date := rosetta_g_miss_date_in_map(p3_a98);
    ddp_x_header_rec.program_application_id := rosetta_g_miss_num_map(p3_a99);
    ddp_x_header_rec.program_id := rosetta_g_miss_num_map(p3_a100);
    ddp_x_header_rec.program_update_date := rosetta_g_miss_date_in_map(p3_a101);
    ddp_x_header_rec.request_date := rosetta_g_miss_date_in_map(p3_a102);
    ddp_x_header_rec.request_id := rosetta_g_miss_num_map(p3_a103);
    ddp_x_header_rec.return_reason_code := p3_a104;
    ddp_x_header_rec.salesrep_id := rosetta_g_miss_num_map(p3_a105);
    ddp_x_header_rec.sales_channel_code := p3_a106;
    ddp_x_header_rec.shipment_priority_code := p3_a107;
    ddp_x_header_rec.shipping_method_code := p3_a108;
    ddp_x_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p3_a109);
    ddp_x_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p3_a110);
    ddp_x_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p3_a111);
    ddp_x_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p3_a112);
    ddp_x_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p3_a113);
    ddp_x_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p3_a114);
    ddp_x_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p3_a115);
    ddp_x_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p3_a116);
    ddp_x_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p3_a117);
    ddp_x_header_rec.source_document_id := rosetta_g_miss_num_map(p3_a118);
    ddp_x_header_rec.source_document_type_id := rosetta_g_miss_num_map(p3_a119);
    ddp_x_header_rec.tax_exempt_flag := p3_a120;
    ddp_x_header_rec.tax_exempt_number := p3_a121;
    ddp_x_header_rec.tax_exempt_reason_code := p3_a122;
    ddp_x_header_rec.tax_point_code := p3_a123;
    ddp_x_header_rec.transactional_curr_code := p3_a124;
    ddp_x_header_rec.version_number := rosetta_g_miss_num_map(p3_a125);
    ddp_x_header_rec.return_status := p3_a126;
    ddp_x_header_rec.db_flag := p3_a127;
    ddp_x_header_rec.operation := p3_a128;
    ddp_x_header_rec.first_ack_code := p3_a129;
    ddp_x_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p3_a130);
    ddp_x_header_rec.last_ack_code := p3_a131;
    ddp_x_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p3_a132);
    ddp_x_header_rec.change_reason := p3_a133;
    ddp_x_header_rec.change_comments := p3_a134;
    ddp_x_header_rec.change_sequence := p3_a135;
    ddp_x_header_rec.change_request_code := p3_a136;
    ddp_x_header_rec.ready_flag := p3_a137;
    ddp_x_header_rec.status_flag := p3_a138;
    ddp_x_header_rec.force_apply_flag := p3_a139;
    ddp_x_header_rec.drop_ship_flag := p3_a140;
    ddp_x_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p3_a141);
    ddp_x_header_rec.payment_type_code := p3_a142;
    ddp_x_header_rec.payment_amount := rosetta_g_miss_num_map(p3_a143);
    ddp_x_header_rec.check_number := p3_a144;
    ddp_x_header_rec.credit_card_code := p3_a145;
    ddp_x_header_rec.credit_card_holder_name := p3_a146;
    ddp_x_header_rec.credit_card_number := p3_a147;
    ddp_x_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p3_a148);
    ddp_x_header_rec.credit_card_approval_code := p3_a149;
    ddp_x_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p3_a150);
    ddp_x_header_rec.shipping_instructions := p3_a151;
    ddp_x_header_rec.packing_instructions := p3_a152;
    ddp_x_header_rec.flow_status_code := p3_a153;
    ddp_x_header_rec.booked_date := rosetta_g_miss_date_in_map(p3_a154);
    ddp_x_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p3_a155);
    ddp_x_header_rec.upgraded_flag := p3_a156;
    ddp_x_header_rec.lock_control := rosetta_g_miss_num_map(p3_a157);
    ddp_x_header_rec.ship_to_edi_location_code := p3_a158;
    ddp_x_header_rec.sold_to_edi_location_code := p3_a159;
    ddp_x_header_rec.bill_to_edi_location_code := p3_a160;
    ddp_x_header_rec.ship_from_edi_location_code := p3_a161;
    ddp_x_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p3_a162);
    ddp_x_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p3_a163);
    ddp_x_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p3_a164);
    ddp_x_header_rec.invoice_address_id := rosetta_g_miss_num_map(p3_a165);
    ddp_x_header_rec.ship_to_address_code := p3_a166;
    ddp_x_header_rec.xml_message_id := rosetta_g_miss_num_map(p3_a167);
    ddp_x_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p3_a168);
    ddp_x_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p3_a169);
    ddp_x_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p3_a170);
    ddp_x_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p3_a171);
    ddp_x_header_rec.xml_transaction_type_code := p3_a172;
    ddp_x_header_rec.blanket_number := rosetta_g_miss_num_map(p3_a173);
    ddp_x_header_rec.line_set_name := p3_a174;
    ddp_x_header_rec.fulfillment_set_name := p3_a175;
    ddp_x_header_rec.default_fulfillment_set := p3_a176;

    ddp_x_old_header_rec.accounting_rule_id := rosetta_g_miss_num_map(p4_a0);
    ddp_x_old_header_rec.agreement_id := rosetta_g_miss_num_map(p4_a1);
    ddp_x_old_header_rec.attribute1 := p4_a2;
    ddp_x_old_header_rec.attribute10 := p4_a3;
    ddp_x_old_header_rec.attribute11 := p4_a4;
    ddp_x_old_header_rec.attribute12 := p4_a5;
    ddp_x_old_header_rec.attribute13 := p4_a6;
    ddp_x_old_header_rec.attribute14 := p4_a7;
    ddp_x_old_header_rec.attribute15 := p4_a8;
    ddp_x_old_header_rec.attribute16 := p4_a9;
    ddp_x_old_header_rec.attribute17 := p4_a10;
    ddp_x_old_header_rec.attribute18 := p4_a11;
    ddp_x_old_header_rec.attribute19 := p4_a12;
    ddp_x_old_header_rec.attribute2 := p4_a13;
    ddp_x_old_header_rec.attribute20 := p4_a14;
    ddp_x_old_header_rec.attribute3 := p4_a15;
    ddp_x_old_header_rec.attribute4 := p4_a16;
    ddp_x_old_header_rec.attribute5 := p4_a17;
    ddp_x_old_header_rec.attribute6 := p4_a18;
    ddp_x_old_header_rec.attribute7 := p4_a19;
    ddp_x_old_header_rec.attribute8 := p4_a20;
    ddp_x_old_header_rec.attribute9 := p4_a21;
    ddp_x_old_header_rec.booked_flag := p4_a22;
    ddp_x_old_header_rec.cancelled_flag := p4_a23;
    ddp_x_old_header_rec.context := p4_a24;
    ddp_x_old_header_rec.conversion_rate := rosetta_g_miss_num_map(p4_a25);
    ddp_x_old_header_rec.conversion_rate_date := rosetta_g_miss_date_in_map(p4_a26);
    ddp_x_old_header_rec.conversion_type_code := p4_a27;
    ddp_x_old_header_rec.customer_preference_set_code := p4_a28;
    ddp_x_old_header_rec.created_by := rosetta_g_miss_num_map(p4_a29);
    ddp_x_old_header_rec.creation_date := rosetta_g_miss_date_in_map(p4_a30);
    ddp_x_old_header_rec.cust_po_number := p4_a31;
    ddp_x_old_header_rec.deliver_to_contact_id := rosetta_g_miss_num_map(p4_a32);
    ddp_x_old_header_rec.deliver_to_org_id := rosetta_g_miss_num_map(p4_a33);
    ddp_x_old_header_rec.demand_class_code := p4_a34;
    ddp_x_old_header_rec.earliest_schedule_limit := rosetta_g_miss_num_map(p4_a35);
    ddp_x_old_header_rec.expiration_date := rosetta_g_miss_date_in_map(p4_a36);
    ddp_x_old_header_rec.fob_point_code := p4_a37;
    ddp_x_old_header_rec.freight_carrier_code := p4_a38;
    ddp_x_old_header_rec.freight_terms_code := p4_a39;
    ddp_x_old_header_rec.global_attribute1 := p4_a40;
    ddp_x_old_header_rec.global_attribute10 := p4_a41;
    ddp_x_old_header_rec.global_attribute11 := p4_a42;
    ddp_x_old_header_rec.global_attribute12 := p4_a43;
    ddp_x_old_header_rec.global_attribute13 := p4_a44;
    ddp_x_old_header_rec.global_attribute14 := p4_a45;
    ddp_x_old_header_rec.global_attribute15 := p4_a46;
    ddp_x_old_header_rec.global_attribute16 := p4_a47;
    ddp_x_old_header_rec.global_attribute17 := p4_a48;
    ddp_x_old_header_rec.global_attribute18 := p4_a49;
    ddp_x_old_header_rec.global_attribute19 := p4_a50;
    ddp_x_old_header_rec.global_attribute2 := p4_a51;
    ddp_x_old_header_rec.global_attribute20 := p4_a52;
    ddp_x_old_header_rec.global_attribute3 := p4_a53;
    ddp_x_old_header_rec.global_attribute4 := p4_a54;
    ddp_x_old_header_rec.global_attribute5 := p4_a55;
    ddp_x_old_header_rec.global_attribute6 := p4_a56;
    ddp_x_old_header_rec.global_attribute7 := p4_a57;
    ddp_x_old_header_rec.global_attribute8 := p4_a58;
    ddp_x_old_header_rec.global_attribute9 := p4_a59;
    ddp_x_old_header_rec.global_attribute_category := p4_a60;
    ddp_x_old_header_rec.tp_context := p4_a61;
    ddp_x_old_header_rec.tp_attribute1 := p4_a62;
    ddp_x_old_header_rec.tp_attribute2 := p4_a63;
    ddp_x_old_header_rec.tp_attribute3 := p4_a64;
    ddp_x_old_header_rec.tp_attribute4 := p4_a65;
    ddp_x_old_header_rec.tp_attribute5 := p4_a66;
    ddp_x_old_header_rec.tp_attribute6 := p4_a67;
    ddp_x_old_header_rec.tp_attribute7 := p4_a68;
    ddp_x_old_header_rec.tp_attribute8 := p4_a69;
    ddp_x_old_header_rec.tp_attribute9 := p4_a70;
    ddp_x_old_header_rec.tp_attribute10 := p4_a71;
    ddp_x_old_header_rec.tp_attribute11 := p4_a72;
    ddp_x_old_header_rec.tp_attribute12 := p4_a73;
    ddp_x_old_header_rec.tp_attribute13 := p4_a74;
    ddp_x_old_header_rec.tp_attribute14 := p4_a75;
    ddp_x_old_header_rec.tp_attribute15 := p4_a76;
    ddp_x_old_header_rec.header_id := rosetta_g_miss_num_map(p4_a77);
    ddp_x_old_header_rec.invoice_to_contact_id := rosetta_g_miss_num_map(p4_a78);
    ddp_x_old_header_rec.invoice_to_org_id := rosetta_g_miss_num_map(p4_a79);
    ddp_x_old_header_rec.invoicing_rule_id := rosetta_g_miss_num_map(p4_a80);
    ddp_x_old_header_rec.last_updated_by := rosetta_g_miss_num_map(p4_a81);
    ddp_x_old_header_rec.last_update_date := rosetta_g_miss_date_in_map(p4_a82);
    ddp_x_old_header_rec.last_update_login := rosetta_g_miss_num_map(p4_a83);
    ddp_x_old_header_rec.latest_schedule_limit := rosetta_g_miss_num_map(p4_a84);
    ddp_x_old_header_rec.open_flag := p4_a85;
    ddp_x_old_header_rec.order_category_code := p4_a86;
    ddp_x_old_header_rec.ordered_date := rosetta_g_miss_date_in_map(p4_a87);
    ddp_x_old_header_rec.order_date_type_code := p4_a88;
    ddp_x_old_header_rec.order_number := rosetta_g_miss_num_map(p4_a89);
    ddp_x_old_header_rec.order_source_id := rosetta_g_miss_num_map(p4_a90);
    ddp_x_old_header_rec.order_type_id := rosetta_g_miss_num_map(p4_a91);
    ddp_x_old_header_rec.org_id := rosetta_g_miss_num_map(p4_a92);
    ddp_x_old_header_rec.orig_sys_document_ref := p4_a93;
    ddp_x_old_header_rec.partial_shipments_allowed := p4_a94;
    ddp_x_old_header_rec.payment_term_id := rosetta_g_miss_num_map(p4_a95);
    ddp_x_old_header_rec.price_list_id := rosetta_g_miss_num_map(p4_a96);
    ddp_x_old_header_rec.price_request_code := p4_a97;
    ddp_x_old_header_rec.pricing_date := rosetta_g_miss_date_in_map(p4_a98);
    ddp_x_old_header_rec.program_application_id := rosetta_g_miss_num_map(p4_a99);
    ddp_x_old_header_rec.program_id := rosetta_g_miss_num_map(p4_a100);
    ddp_x_old_header_rec.program_update_date := rosetta_g_miss_date_in_map(p4_a101);
    ddp_x_old_header_rec.request_date := rosetta_g_miss_date_in_map(p4_a102);
    ddp_x_old_header_rec.request_id := rosetta_g_miss_num_map(p4_a103);
    ddp_x_old_header_rec.return_reason_code := p4_a104;
    ddp_x_old_header_rec.salesrep_id := rosetta_g_miss_num_map(p4_a105);
    ddp_x_old_header_rec.sales_channel_code := p4_a106;
    ddp_x_old_header_rec.shipment_priority_code := p4_a107;
    ddp_x_old_header_rec.shipping_method_code := p4_a108;
    ddp_x_old_header_rec.ship_from_org_id := rosetta_g_miss_num_map(p4_a109);
    ddp_x_old_header_rec.ship_tolerance_above := rosetta_g_miss_num_map(p4_a110);
    ddp_x_old_header_rec.ship_tolerance_below := rosetta_g_miss_num_map(p4_a111);
    ddp_x_old_header_rec.ship_to_contact_id := rosetta_g_miss_num_map(p4_a112);
    ddp_x_old_header_rec.ship_to_org_id := rosetta_g_miss_num_map(p4_a113);
    ddp_x_old_header_rec.sold_from_org_id := rosetta_g_miss_num_map(p4_a114);
    ddp_x_old_header_rec.sold_to_contact_id := rosetta_g_miss_num_map(p4_a115);
    ddp_x_old_header_rec.sold_to_org_id := rosetta_g_miss_num_map(p4_a116);
    ddp_x_old_header_rec.sold_to_phone_id := rosetta_g_miss_num_map(p4_a117);
    ddp_x_old_header_rec.source_document_id := rosetta_g_miss_num_map(p4_a118);
    ddp_x_old_header_rec.source_document_type_id := rosetta_g_miss_num_map(p4_a119);
    ddp_x_old_header_rec.tax_exempt_flag := p4_a120;
    ddp_x_old_header_rec.tax_exempt_number := p4_a121;
    ddp_x_old_header_rec.tax_exempt_reason_code := p4_a122;
    ddp_x_old_header_rec.tax_point_code := p4_a123;
    ddp_x_old_header_rec.transactional_curr_code := p4_a124;
    ddp_x_old_header_rec.version_number := rosetta_g_miss_num_map(p4_a125);
    ddp_x_old_header_rec.return_status := p4_a126;
    ddp_x_old_header_rec.db_flag := p4_a127;
    ddp_x_old_header_rec.operation := p4_a128;
    ddp_x_old_header_rec.first_ack_code := p4_a129;
    ddp_x_old_header_rec.first_ack_date := rosetta_g_miss_date_in_map(p4_a130);
    ddp_x_old_header_rec.last_ack_code := p4_a131;
    ddp_x_old_header_rec.last_ack_date := rosetta_g_miss_date_in_map(p4_a132);
    ddp_x_old_header_rec.change_reason := p4_a133;
    ddp_x_old_header_rec.change_comments := p4_a134;
    ddp_x_old_header_rec.change_sequence := p4_a135;
    ddp_x_old_header_rec.change_request_code := p4_a136;
    ddp_x_old_header_rec.ready_flag := p4_a137;
    ddp_x_old_header_rec.status_flag := p4_a138;
    ddp_x_old_header_rec.force_apply_flag := p4_a139;
    ddp_x_old_header_rec.drop_ship_flag := p4_a140;
    ddp_x_old_header_rec.customer_payment_term_id := rosetta_g_miss_num_map(p4_a141);
    ddp_x_old_header_rec.payment_type_code := p4_a142;
    ddp_x_old_header_rec.payment_amount := rosetta_g_miss_num_map(p4_a143);
    ddp_x_old_header_rec.check_number := p4_a144;
    ddp_x_old_header_rec.credit_card_code := p4_a145;
    ddp_x_old_header_rec.credit_card_holder_name := p4_a146;
    ddp_x_old_header_rec.credit_card_number := p4_a147;
    ddp_x_old_header_rec.credit_card_expiration_date := rosetta_g_miss_date_in_map(p4_a148);
    ddp_x_old_header_rec.credit_card_approval_code := p4_a149;
    ddp_x_old_header_rec.credit_card_approval_date := rosetta_g_miss_date_in_map(p4_a150);
    ddp_x_old_header_rec.shipping_instructions := p4_a151;
    ddp_x_old_header_rec.packing_instructions := p4_a152;
    ddp_x_old_header_rec.flow_status_code := p4_a153;
    ddp_x_old_header_rec.booked_date := rosetta_g_miss_date_in_map(p4_a154);
    ddp_x_old_header_rec.marketing_source_code_id := rosetta_g_miss_num_map(p4_a155);
    ddp_x_old_header_rec.upgraded_flag := p4_a156;
    ddp_x_old_header_rec.lock_control := rosetta_g_miss_num_map(p4_a157);
    ddp_x_old_header_rec.ship_to_edi_location_code := p4_a158;
    ddp_x_old_header_rec.sold_to_edi_location_code := p4_a159;
    ddp_x_old_header_rec.bill_to_edi_location_code := p4_a160;
    ddp_x_old_header_rec.ship_from_edi_location_code := p4_a161;
    ddp_x_old_header_rec.ship_from_address_id := rosetta_g_miss_num_map(p4_a162);
    ddp_x_old_header_rec.sold_to_address_id := rosetta_g_miss_num_map(p4_a163);
    ddp_x_old_header_rec.ship_to_address_id := rosetta_g_miss_num_map(p4_a164);
    ddp_x_old_header_rec.invoice_address_id := rosetta_g_miss_num_map(p4_a165);
    ddp_x_old_header_rec.ship_to_address_code := p4_a166;
    ddp_x_old_header_rec.xml_message_id := rosetta_g_miss_num_map(p4_a167);
    ddp_x_old_header_rec.ship_to_customer_id := rosetta_g_miss_num_map(p4_a168);
    ddp_x_old_header_rec.invoice_to_customer_id := rosetta_g_miss_num_map(p4_a169);
    ddp_x_old_header_rec.deliver_to_customer_id := rosetta_g_miss_num_map(p4_a170);
    ddp_x_old_header_rec.accounting_rule_duration := rosetta_g_miss_num_map(p4_a171);
    ddp_x_old_header_rec.xml_transaction_type_code := p4_a172;
    ddp_x_old_header_rec.blanket_number := rosetta_g_miss_num_map(p4_a173);
    ddp_x_old_header_rec.line_set_name := p4_a174;
    ddp_x_old_header_rec.fulfillment_set_name := p4_a175;
    ddp_x_old_header_rec.default_fulfillment_set := p4_a176;
    ddp_x_old_header_rec.transaction_phase_code:='F';
    ddp_x_header_rec.transaction_phase_code:='F';


    oe_debug_pub.g_debug_level := FND_PROFILE.VALUE('ONT_DEBUG_LEVEL');
    l_fname := oe_Debug_pub.set_debug_mode('FILE');

    oe_debug_pub.debug_on;


    -- here's the delegated call to the old PL/SQL routine
    oe_order_pvt.header(p_init_msg_list,
      p_validation_level,
      ddp_control_rec,
      ddp_x_header_rec,
      ddp_x_old_header_rec,
      x_return_status);

    -- copy data back from the local variables to OUT or IN-OUT args, if any



    p3_a0 := rosetta_g_miss_num_map(ddp_x_header_rec.accounting_rule_id);
    p3_a1 := rosetta_g_miss_num_map(ddp_x_header_rec.agreement_id);
    p3_a2 := ddp_x_header_rec.attribute1;
    p3_a3 := ddp_x_header_rec.attribute10;
    p3_a4 := ddp_x_header_rec.attribute11;
    p3_a5 := ddp_x_header_rec.attribute12;
    p3_a6 := ddp_x_header_rec.attribute13;
    p3_a7 := ddp_x_header_rec.attribute14;
    p3_a8 := ddp_x_header_rec.attribute15;
    p3_a9 := ddp_x_header_rec.attribute16;
    p3_a10 := ddp_x_header_rec.attribute17;
    p3_a11 := ddp_x_header_rec.attribute18;
    p3_a12 := ddp_x_header_rec.attribute19;
    p3_a13 := ddp_x_header_rec.attribute2;
    p3_a14 := ddp_x_header_rec.attribute20;
    p3_a15 := ddp_x_header_rec.attribute3;
    p3_a16 := ddp_x_header_rec.attribute4;
    p3_a17 := ddp_x_header_rec.attribute5;
    p3_a18 := ddp_x_header_rec.attribute6;
    p3_a19 := ddp_x_header_rec.attribute7;
    p3_a20 := ddp_x_header_rec.attribute8;
    p3_a21 := ddp_x_header_rec.attribute9;
    p3_a22 := ddp_x_header_rec.booked_flag;
    p3_a23 := ddp_x_header_rec.cancelled_flag;
    p3_a24 := ddp_x_header_rec.context;
    p3_a25 := rosetta_g_miss_num_map(ddp_x_header_rec.conversion_rate);
    p3_a26 := ddp_x_header_rec.conversion_rate_date;
    p3_a27 := ddp_x_header_rec.conversion_type_code;
    p3_a28 := ddp_x_header_rec.customer_preference_set_code;
    p3_a29 := rosetta_g_miss_num_map(ddp_x_header_rec.created_by);
    p3_a30 := ddp_x_header_rec.creation_date;
    p3_a31 := ddp_x_header_rec.cust_po_number;
    p3_a32 := rosetta_g_miss_num_map(ddp_x_header_rec.deliver_to_contact_id);
    p3_a33 := rosetta_g_miss_num_map(ddp_x_header_rec.deliver_to_org_id);
    p3_a34 := ddp_x_header_rec.demand_class_code;
    p3_a35 := rosetta_g_miss_num_map(ddp_x_header_rec.earliest_schedule_limit);
    p3_a36 := ddp_x_header_rec.expiration_date;
    p3_a37 := ddp_x_header_rec.fob_point_code;
    p3_a38 := ddp_x_header_rec.freight_carrier_code;
    p3_a39 := ddp_x_header_rec.freight_terms_code;
    p3_a40 := ddp_x_header_rec.global_attribute1;
    p3_a41 := ddp_x_header_rec.global_attribute10;
    p3_a42 := ddp_x_header_rec.global_attribute11;
    p3_a43 := ddp_x_header_rec.global_attribute12;
    p3_a44 := ddp_x_header_rec.global_attribute13;
    p3_a45 := ddp_x_header_rec.global_attribute14;
    p3_a46 := ddp_x_header_rec.global_attribute15;
    p3_a47 := ddp_x_header_rec.global_attribute16;
    p3_a48 := ddp_x_header_rec.global_attribute17;
    p3_a49 := ddp_x_header_rec.global_attribute18;
    p3_a50 := ddp_x_header_rec.global_attribute19;
    p3_a51 := ddp_x_header_rec.global_attribute2;
    p3_a52 := ddp_x_header_rec.global_attribute20;
    p3_a53 := ddp_x_header_rec.global_attribute3;
    p3_a54 := ddp_x_header_rec.global_attribute4;
    p3_a55 := ddp_x_header_rec.global_attribute5;
    p3_a56 := ddp_x_header_rec.global_attribute6;
    p3_a57 := ddp_x_header_rec.global_attribute7;
    p3_a58 := ddp_x_header_rec.global_attribute8;
    p3_a59 := ddp_x_header_rec.global_attribute9;
    p3_a60 := ddp_x_header_rec.global_attribute_category;
    p3_a61 := ddp_x_header_rec.tp_context;
    p3_a62 := ddp_x_header_rec.tp_attribute1;
    p3_a63 := ddp_x_header_rec.tp_attribute2;
    p3_a64 := ddp_x_header_rec.tp_attribute3;
    p3_a65 := ddp_x_header_rec.tp_attribute4;
    p3_a66 := ddp_x_header_rec.tp_attribute5;
    p3_a67 := ddp_x_header_rec.tp_attribute6;
    p3_a68 := ddp_x_header_rec.tp_attribute7;
    p3_a69 := ddp_x_header_rec.tp_attribute8;
    p3_a70 := ddp_x_header_rec.tp_attribute9;
    p3_a71 := ddp_x_header_rec.tp_attribute10;
    p3_a72 := ddp_x_header_rec.tp_attribute11;
    p3_a73 := ddp_x_header_rec.tp_attribute12;
    p3_a74 := ddp_x_header_rec.tp_attribute13;
    p3_a75 := ddp_x_header_rec.tp_attribute14;
    p3_a76 := ddp_x_header_rec.tp_attribute15;
    p3_a77 := rosetta_g_miss_num_map(ddp_x_header_rec.header_id);
    p3_a78 := rosetta_g_miss_num_map(ddp_x_header_rec.invoice_to_contact_id);
    p3_a79 := rosetta_g_miss_num_map(ddp_x_header_rec.invoice_to_org_id);
    p3_a80 := rosetta_g_miss_num_map(ddp_x_header_rec.invoicing_rule_id);
    p3_a81 := rosetta_g_miss_num_map(ddp_x_header_rec.last_updated_by);
    p3_a82 := ddp_x_header_rec.last_update_date;
    p3_a83 := rosetta_g_miss_num_map(ddp_x_header_rec.last_update_login);
    p3_a84 := rosetta_g_miss_num_map(ddp_x_header_rec.latest_schedule_limit);
    p3_a85 := ddp_x_header_rec.open_flag;
    p3_a86 := ddp_x_header_rec.order_category_code;
    p3_a87 := ddp_x_header_rec.ordered_date;
    p3_a88 := ddp_x_header_rec.order_date_type_code;
    p3_a89 := rosetta_g_miss_num_map(ddp_x_header_rec.order_number);
    p3_a90 := rosetta_g_miss_num_map(ddp_x_header_rec.order_source_id);
    p3_a91 := rosetta_g_miss_num_map(ddp_x_header_rec.order_type_id);
    p3_a92 := rosetta_g_miss_num_map(ddp_x_header_rec.org_id);
    p3_a93 := ddp_x_header_rec.orig_sys_document_ref;
    p3_a94 := ddp_x_header_rec.partial_shipments_allowed;
    p3_a95 := rosetta_g_miss_num_map(ddp_x_header_rec.payment_term_id);
    p3_a96 := rosetta_g_miss_num_map(ddp_x_header_rec.price_list_id);
    p3_a97 := ddp_x_header_rec.price_request_code;
    p3_a98 := ddp_x_header_rec.pricing_date;
    p3_a99 := rosetta_g_miss_num_map(ddp_x_header_rec.program_application_id);
    p3_a100 := rosetta_g_miss_num_map(ddp_x_header_rec.program_id);
    p3_a101 := ddp_x_header_rec.program_update_date;
    p3_a102 := ddp_x_header_rec.request_date;
    p3_a103 := rosetta_g_miss_num_map(ddp_x_header_rec.request_id);
    p3_a104 := ddp_x_header_rec.return_reason_code;
    p3_a105 := rosetta_g_miss_num_map(ddp_x_header_rec.salesrep_id);
    p3_a106 := ddp_x_header_rec.sales_channel_code;
    p3_a107 := ddp_x_header_rec.shipment_priority_code;
    p3_a108 := ddp_x_header_rec.shipping_method_code;
    p3_a109 := rosetta_g_miss_num_map(ddp_x_header_rec.ship_from_org_id);
    p3_a110 := rosetta_g_miss_num_map(ddp_x_header_rec.ship_tolerance_above);
    p3_a111 := rosetta_g_miss_num_map(ddp_x_header_rec.ship_tolerance_below);
    p3_a112 := rosetta_g_miss_num_map(ddp_x_header_rec.ship_to_contact_id);
    p3_a113 := rosetta_g_miss_num_map(ddp_x_header_rec.ship_to_org_id);
    p3_a114 := rosetta_g_miss_num_map(ddp_x_header_rec.sold_from_org_id);
    p3_a115 := rosetta_g_miss_num_map(ddp_x_header_rec.sold_to_contact_id);
    p3_a116 := rosetta_g_miss_num_map(ddp_x_header_rec.sold_to_org_id);
    p3_a117 := rosetta_g_miss_num_map(ddp_x_header_rec.sold_to_phone_id);
    p3_a118 := rosetta_g_miss_num_map(ddp_x_header_rec.source_document_id);
    p3_a119 := rosetta_g_miss_num_map(ddp_x_header_rec.source_document_type_id);
    p3_a120 := ddp_x_header_rec.tax_exempt_flag;
    p3_a121 := ddp_x_header_rec.tax_exempt_number;
    p3_a122 := ddp_x_header_rec.tax_exempt_reason_code;
    p3_a123 := ddp_x_header_rec.tax_point_code;
    p3_a124 := ddp_x_header_rec.transactional_curr_code;
    p3_a125 := rosetta_g_miss_num_map(ddp_x_header_rec.version_number);
    p3_a126 := ddp_x_header_rec.return_status;
    p3_a127 := ddp_x_header_rec.db_flag;
    p3_a128 := ddp_x_header_rec.operation;
    p3_a129 := ddp_x_header_rec.first_ack_code;
    p3_a130 := ddp_x_header_rec.first_ack_date;
    p3_a131 := ddp_x_header_rec.last_ack_code;
    p3_a132 := ddp_x_header_rec.last_ack_date;
    p3_a133 := ddp_x_header_rec.change_reason;
    p3_a134 := ddp_x_header_rec.change_comments;
    p3_a135 := ddp_x_header_rec.change_sequence;
    p3_a136 := ddp_x_header_rec.change_request_code;
    p3_a137 := ddp_x_header_rec.ready_flag;
    p3_a138 := ddp_x_header_rec.status_flag;
    p3_a139 := ddp_x_header_rec.force_apply_flag;
    p3_a140 := ddp_x_header_rec.drop_ship_flag;
    p3_a141 := rosetta_g_miss_num_map(ddp_x_header_rec.customer_payment_term_id);
    p3_a142 := ddp_x_header_rec.payment_type_code;
    p3_a143 := rosetta_g_miss_num_map(ddp_x_header_rec.payment_amount);
    p3_a144 := ddp_x_header_rec.check_number;
    p3_a145 := ddp_x_header_rec.credit_card_code;
    p3_a146 := ddp_x_header_rec.credit_card_holder_name;
    p3_a147 := ddp_x_header_rec.credit_card_number;
    p3_a148 := ddp_x_header_rec.credit_card_expiration_date;
    p3_a149 := ddp_x_header_rec.credit_card_approval_code;
    p3_a150 := ddp_x_header_rec.credit_card_approval_date;
    p3_a151 := ddp_x_header_rec.shipping_instructions;
    p3_a152 := ddp_x_header_rec.packing_instructions;
    p3_a153 := ddp_x_header_rec.flow_status_code;
    p3_a154 := ddp_x_header_rec.booked_date;
    p3_a155 := rosetta_g_miss_num_map(ddp_x_header_rec.marketing_source_code_id);
    p3_a156 := ddp_x_header_rec.upgraded_flag;
    p3_a157 := rosetta_g_miss_num_map(ddp_x_header_rec.lock_control);
    p3_a158 := ddp_x_header_rec.ship_to_edi_location_code;
    p3_a159 := ddp_x_header_rec.sold_to_edi_location_code;
    p3_a160 := ddp_x_header_rec.bill_to_edi_location_code;
    p3_a161 := ddp_x_header_rec.ship_from_edi_location_code;
    p3_a162 := rosetta_g_miss_num_map(ddp_x_header_rec.ship_from_address_id);
    p3_a163 := rosetta_g_miss_num_map(ddp_x_header_rec.sold_to_address_id);
    p3_a164 := rosetta_g_miss_num_map(ddp_x_header_rec.ship_to_address_id);
    p3_a165 := rosetta_g_miss_num_map(ddp_x_header_rec.invoice_address_id);
    p3_a166 := ddp_x_header_rec.ship_to_address_code;
    p3_a167 := rosetta_g_miss_num_map(ddp_x_header_rec.xml_message_id);
    p3_a168 := rosetta_g_miss_num_map(ddp_x_header_rec.ship_to_customer_id);
    p3_a169 := rosetta_g_miss_num_map(ddp_x_header_rec.invoice_to_customer_id);
    p3_a170 := rosetta_g_miss_num_map(ddp_x_header_rec.deliver_to_customer_id);
    p3_a171 := rosetta_g_miss_num_map(ddp_x_header_rec.accounting_rule_duration);
    p3_a172 := ddp_x_header_rec.xml_transaction_type_code;
    p3_a173 := rosetta_g_miss_num_map(ddp_x_header_rec.blanket_number);
    p3_a174 := ddp_x_header_rec.line_set_name;
    p3_a175 := ddp_x_header_rec.fulfillment_set_name;
    p3_a176 := ddp_x_header_rec.default_fulfillment_set;

    p4_a0 := rosetta_g_miss_num_map(ddp_x_old_header_rec.accounting_rule_id);
    p4_a1 := rosetta_g_miss_num_map(ddp_x_old_header_rec.agreement_id);
    p4_a2 := ddp_x_old_header_rec.attribute1;
    p4_a3 := ddp_x_old_header_rec.attribute10;
    p4_a4 := ddp_x_old_header_rec.attribute11;
    p4_a5 := ddp_x_old_header_rec.attribute12;
    p4_a6 := ddp_x_old_header_rec.attribute13;
    p4_a7 := ddp_x_old_header_rec.attribute14;
    p4_a8 := ddp_x_old_header_rec.attribute15;
    p4_a9 := ddp_x_old_header_rec.attribute16;
    p4_a10 := ddp_x_old_header_rec.attribute17;
    p4_a11 := ddp_x_old_header_rec.attribute18;
    p4_a12 := ddp_x_old_header_rec.attribute19;
    p4_a13 := ddp_x_old_header_rec.attribute2;
    p4_a14 := ddp_x_old_header_rec.attribute20;
    p4_a15 := ddp_x_old_header_rec.attribute3;
    p4_a16 := ddp_x_old_header_rec.attribute4;
    p4_a17 := ddp_x_old_header_rec.attribute5;
    p4_a18 := ddp_x_old_header_rec.attribute6;
    p4_a19 := ddp_x_old_header_rec.attribute7;
    p4_a20 := ddp_x_old_header_rec.attribute8;
    p4_a21 := ddp_x_old_header_rec.attribute9;
    p4_a22 := ddp_x_old_header_rec.booked_flag;
    p4_a23 := ddp_x_old_header_rec.cancelled_flag;
    p4_a24 := ddp_x_old_header_rec.context;
    p4_a25 := rosetta_g_miss_num_map(ddp_x_old_header_rec.conversion_rate);
    p4_a26 := ddp_x_old_header_rec.conversion_rate_date;
    p4_a27 := ddp_x_old_header_rec.conversion_type_code;
    p4_a28 := ddp_x_old_header_rec.customer_preference_set_code;
    p4_a29 := rosetta_g_miss_num_map(ddp_x_old_header_rec.created_by);
    p4_a30 := ddp_x_old_header_rec.creation_date;
    p4_a31 := ddp_x_old_header_rec.cust_po_number;
    p4_a32 := rosetta_g_miss_num_map(ddp_x_old_header_rec.deliver_to_contact_id);
    p4_a33 := rosetta_g_miss_num_map(ddp_x_old_header_rec.deliver_to_org_id);
    p4_a34 := ddp_x_old_header_rec.demand_class_code;
    p4_a35 := rosetta_g_miss_num_map(ddp_x_old_header_rec.earliest_schedule_limit);
    p4_a36 := ddp_x_old_header_rec.expiration_date;
    p4_a37 := ddp_x_old_header_rec.fob_point_code;
    p4_a38 := ddp_x_old_header_rec.freight_carrier_code;
    p4_a39 := ddp_x_old_header_rec.freight_terms_code;
    p4_a40 := ddp_x_old_header_rec.global_attribute1;
    p4_a41 := ddp_x_old_header_rec.global_attribute10;
    p4_a42 := ddp_x_old_header_rec.global_attribute11;
    p4_a43 := ddp_x_old_header_rec.global_attribute12;
    p4_a44 := ddp_x_old_header_rec.global_attribute13;
    p4_a45 := ddp_x_old_header_rec.global_attribute14;
    p4_a46 := ddp_x_old_header_rec.global_attribute15;
    p4_a47 := ddp_x_old_header_rec.global_attribute16;
    p4_a48 := ddp_x_old_header_rec.global_attribute17;
    p4_a49 := ddp_x_old_header_rec.global_attribute18;
    p4_a50 := ddp_x_old_header_rec.global_attribute19;
    p4_a51 := ddp_x_old_header_rec.global_attribute2;
    p4_a52 := ddp_x_old_header_rec.global_attribute20;
    p4_a53 := ddp_x_old_header_rec.global_attribute3;
    p4_a54 := ddp_x_old_header_rec.global_attribute4;
    p4_a55 := ddp_x_old_header_rec.global_attribute5;
    p4_a56 := ddp_x_old_header_rec.global_attribute6;
    p4_a57 := ddp_x_old_header_rec.global_attribute7;
    p4_a58 := ddp_x_old_header_rec.global_attribute8;
    p4_a59 := ddp_x_old_header_rec.global_attribute9;
    p4_a60 := ddp_x_old_header_rec.global_attribute_category;
    p4_a61 := ddp_x_old_header_rec.tp_context;
    p4_a62 := ddp_x_old_header_rec.tp_attribute1;
    p4_a63 := ddp_x_old_header_rec.tp_attribute2;
    p4_a64 := ddp_x_old_header_rec.tp_attribute3;
    p4_a65 := ddp_x_old_header_rec.tp_attribute4;
    p4_a66 := ddp_x_old_header_rec.tp_attribute5;
    p4_a67 := ddp_x_old_header_rec.tp_attribute6;
    p4_a68 := ddp_x_old_header_rec.tp_attribute7;
    p4_a69 := ddp_x_old_header_rec.tp_attribute8;
    p4_a70 := ddp_x_old_header_rec.tp_attribute9;
    p4_a71 := ddp_x_old_header_rec.tp_attribute10;
    p4_a72 := ddp_x_old_header_rec.tp_attribute11;
    p4_a73 := ddp_x_old_header_rec.tp_attribute12;
    p4_a74 := ddp_x_old_header_rec.tp_attribute13;
    p4_a75 := ddp_x_old_header_rec.tp_attribute14;
    p4_a76 := ddp_x_old_header_rec.tp_attribute15;
    p4_a77 := rosetta_g_miss_num_map(ddp_x_old_header_rec.header_id);
    p4_a78 := rosetta_g_miss_num_map(ddp_x_old_header_rec.invoice_to_contact_id);
    p4_a79 := rosetta_g_miss_num_map(ddp_x_old_header_rec.invoice_to_org_id);
    p4_a80 := rosetta_g_miss_num_map(ddp_x_old_header_rec.invoicing_rule_id);
    p4_a81 := rosetta_g_miss_num_map(ddp_x_old_header_rec.last_updated_by);
    p4_a82 := ddp_x_old_header_rec.last_update_date;
    p4_a83 := rosetta_g_miss_num_map(ddp_x_old_header_rec.last_update_login);
    p4_a84 := rosetta_g_miss_num_map(ddp_x_old_header_rec.latest_schedule_limit);
    p4_a85 := ddp_x_old_header_rec.open_flag;
    p4_a86 := ddp_x_old_header_rec.order_category_code;
    p4_a87 := ddp_x_old_header_rec.ordered_date;
    p4_a88 := ddp_x_old_header_rec.order_date_type_code;
    p4_a89 := rosetta_g_miss_num_map(ddp_x_old_header_rec.order_number);
    p4_a90 := rosetta_g_miss_num_map(ddp_x_old_header_rec.order_source_id);
    p4_a91 := rosetta_g_miss_num_map(ddp_x_old_header_rec.order_type_id);
    p4_a92 := rosetta_g_miss_num_map(ddp_x_old_header_rec.org_id);
    p4_a93 := ddp_x_old_header_rec.orig_sys_document_ref;
    p4_a94 := ddp_x_old_header_rec.partial_shipments_allowed;
    p4_a95 := rosetta_g_miss_num_map(ddp_x_old_header_rec.payment_term_id);
    p4_a96 := rosetta_g_miss_num_map(ddp_x_old_header_rec.price_list_id);
    p4_a97 := ddp_x_old_header_rec.price_request_code;
    p4_a98 := ddp_x_old_header_rec.pricing_date;
    p4_a99 := rosetta_g_miss_num_map(ddp_x_old_header_rec.program_application_id);
    p4_a100 := rosetta_g_miss_num_map(ddp_x_old_header_rec.program_id);
    p4_a101 := ddp_x_old_header_rec.program_update_date;
    p4_a102 := ddp_x_old_header_rec.request_date;
    p4_a103 := rosetta_g_miss_num_map(ddp_x_old_header_rec.request_id);
    p4_a104 := ddp_x_old_header_rec.return_reason_code;
    p4_a105 := rosetta_g_miss_num_map(ddp_x_old_header_rec.salesrep_id);
    p4_a106 := ddp_x_old_header_rec.sales_channel_code;
    p4_a107 := ddp_x_old_header_rec.shipment_priority_code;
    p4_a108 := ddp_x_old_header_rec.shipping_method_code;
    p4_a109 := rosetta_g_miss_num_map(ddp_x_old_header_rec.ship_from_org_id);
    p4_a110 := rosetta_g_miss_num_map(ddp_x_old_header_rec.ship_tolerance_above);
    p4_a111 := rosetta_g_miss_num_map(ddp_x_old_header_rec.ship_tolerance_below);
    p4_a112 := rosetta_g_miss_num_map(ddp_x_old_header_rec.ship_to_contact_id);
    p4_a113 := rosetta_g_miss_num_map(ddp_x_old_header_rec.ship_to_org_id);
    p4_a114 := rosetta_g_miss_num_map(ddp_x_old_header_rec.sold_from_org_id);
    p4_a115 := rosetta_g_miss_num_map(ddp_x_old_header_rec.sold_to_contact_id);
    p4_a116 := rosetta_g_miss_num_map(ddp_x_old_header_rec.sold_to_org_id);
    p4_a117 := rosetta_g_miss_num_map(ddp_x_old_header_rec.sold_to_phone_id);
    p4_a118 := rosetta_g_miss_num_map(ddp_x_old_header_rec.source_document_id);
    p4_a119 := rosetta_g_miss_num_map(ddp_x_old_header_rec.source_document_type_id);
    p4_a120 := ddp_x_old_header_rec.tax_exempt_flag;
    p4_a121 := ddp_x_old_header_rec.tax_exempt_number;
    p4_a122 := ddp_x_old_header_rec.tax_exempt_reason_code;
    p4_a123 := ddp_x_old_header_rec.tax_point_code;
    p4_a124 := ddp_x_old_header_rec.transactional_curr_code;
    p4_a125 := rosetta_g_miss_num_map(ddp_x_old_header_rec.version_number);
    p4_a126 := ddp_x_old_header_rec.return_status;
    p4_a127 := ddp_x_old_header_rec.db_flag;
    p4_a128 := ddp_x_old_header_rec.operation;
    p4_a129 := ddp_x_old_header_rec.first_ack_code;
    p4_a130 := ddp_x_old_header_rec.first_ack_date;
    p4_a131 := ddp_x_old_header_rec.last_ack_code;
    p4_a132 := ddp_x_old_header_rec.last_ack_date;
    p4_a133 := ddp_x_old_header_rec.change_reason;
    p4_a134 := ddp_x_old_header_rec.change_comments;
    p4_a135 := ddp_x_old_header_rec.change_sequence;
    p4_a136 := ddp_x_old_header_rec.change_request_code;
    p4_a137 := ddp_x_old_header_rec.ready_flag;
    p4_a138 := ddp_x_old_header_rec.status_flag;
    p4_a139 := ddp_x_old_header_rec.force_apply_flag;
    p4_a140 := ddp_x_old_header_rec.drop_ship_flag;
    p4_a141 := rosetta_g_miss_num_map(ddp_x_old_header_rec.customer_payment_term_id);
    p4_a142 := ddp_x_old_header_rec.payment_type_code;
    p4_a143 := rosetta_g_miss_num_map(ddp_x_old_header_rec.payment_amount);
    p4_a144 := ddp_x_old_header_rec.check_number;
    p4_a145 := ddp_x_old_header_rec.credit_card_code;
    p4_a146 := ddp_x_old_header_rec.credit_card_holder_name;
    p4_a147 := ddp_x_old_header_rec.credit_card_number;
    p4_a148 := ddp_x_old_header_rec.credit_card_expiration_date;
    p4_a149 := ddp_x_old_header_rec.credit_card_approval_code;
    p4_a150 := ddp_x_old_header_rec.credit_card_approval_date;
    p4_a151 := ddp_x_old_header_rec.shipping_instructions;
    p4_a152 := ddp_x_old_header_rec.packing_instructions;
    p4_a153 := ddp_x_old_header_rec.flow_status_code;
    p4_a154 := ddp_x_old_header_rec.booked_date;
    p4_a155 := rosetta_g_miss_num_map(ddp_x_old_header_rec.marketing_source_code_id);
    p4_a156 := ddp_x_old_header_rec.upgraded_flag;
    p4_a157 := rosetta_g_miss_num_map(ddp_x_old_header_rec.lock_control);
    p4_a158 := ddp_x_old_header_rec.ship_to_edi_location_code;
    p4_a159 := ddp_x_old_header_rec.sold_to_edi_location_code;
    p4_a160 := ddp_x_old_header_rec.bill_to_edi_location_code;
    p4_a161 := ddp_x_old_header_rec.ship_from_edi_location_code;
    p4_a162 := rosetta_g_miss_num_map(ddp_x_old_header_rec.ship_from_address_id);
    p4_a163 := rosetta_g_miss_num_map(ddp_x_old_header_rec.sold_to_address_id);
    p4_a164 := rosetta_g_miss_num_map(ddp_x_old_header_rec.ship_to_address_id);
    p4_a165 := rosetta_g_miss_num_map(ddp_x_old_header_rec.invoice_address_id);
    p4_a166 := ddp_x_old_header_rec.ship_to_address_code;
    p4_a167 := rosetta_g_miss_num_map(ddp_x_old_header_rec.xml_message_id);
    p4_a168 := rosetta_g_miss_num_map(ddp_x_old_header_rec.ship_to_customer_id);
    p4_a169 := rosetta_g_miss_num_map(ddp_x_old_header_rec.invoice_to_customer_id);
    p4_a170 := rosetta_g_miss_num_map(ddp_x_old_header_rec.deliver_to_customer_id);
    p4_a171 := rosetta_g_miss_num_map(ddp_x_old_header_rec.accounting_rule_duration);
    p4_a172 := ddp_x_old_header_rec.xml_transaction_type_code;
    p4_a173 := rosetta_g_miss_num_map(ddp_x_old_header_rec.blanket_number);
    p4_a174 := ddp_x_old_header_rec.line_set_name;
    p4_a175 := ddp_x_old_header_rec.fulfillment_set_name;
    p4_a176 := ddp_x_old_header_rec.default_fulfillment_set;

  end;

end oe_order_pvt_w;

/
