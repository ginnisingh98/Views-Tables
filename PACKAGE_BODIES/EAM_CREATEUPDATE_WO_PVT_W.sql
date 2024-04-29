--------------------------------------------------------
--  DDL for Package Body EAM_CREATEUPDATE_WO_PVT_W
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_CREATEUPDATE_WO_PVT_W" as
  /* $Header: EAMVWOCB.pls 120.8.12010000.3 2012/06/27 13:39:55 rsandepo ship $ */
  procedure create_update_wo(p_commit  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_VARCHAR2_TABLE_300
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_VARCHAR2_TABLE_300
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_NUMBER_TABLE
    , p1_a10 JTF_VARCHAR2_TABLE_100
    , p1_a11 JTF_NUMBER_TABLE
    , p1_a12 JTF_NUMBER_TABLE
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_VARCHAR2_TABLE_100
    , p1_a16 JTF_NUMBER_TABLE
    , p1_a17 JTF_VARCHAR2_TABLE_100
    , p1_a18 JTF_VARCHAR2_TABLE_100
    , p1_a19 JTF_VARCHAR2_TABLE_100
    , p1_a20 JTF_VARCHAR2_TABLE_100
    , p1_a21 JTF_NUMBER_TABLE
    , p1_a22 JTF_NUMBER_TABLE
    , p1_a23 JTF_DATE_TABLE
    , p1_a24 JTF_NUMBER_TABLE
    , p1_a25 JTF_NUMBER_TABLE
    , p1_a26 JTF_DATE_TABLE
    , p1_a27 JTF_DATE_TABLE
    , p1_a28 JTF_VARCHAR2_TABLE_100
    , p1_a29 JTF_NUMBER_TABLE
    , p1_a30 JTF_VARCHAR2_TABLE_100
    , p1_a31 JTF_VARCHAR2_TABLE_100
    , p1_a32 JTF_VARCHAR2_TABLE_100
    , p1_a33 JTF_NUMBER_TABLE
    , p1_a34 JTF_NUMBER_TABLE
    , p1_a35 JTF_VARCHAR2_TABLE_100
    , p1_a36 JTF_NUMBER_TABLE
    , p1_a37 JTF_DATE_TABLE
    , p1_a38 JTF_DATE_TABLE
    , p1_a39 JTF_VARCHAR2_TABLE_100
    , p1_a40 JTF_VARCHAR2_TABLE_100
    , p1_a41 JTF_VARCHAR2_TABLE_100
    , p1_a42 JTF_VARCHAR2_TABLE_100
    , p1_a43 JTF_NUMBER_TABLE
    , p1_a44 JTF_VARCHAR2_TABLE_100
    , p1_a45 JTF_NUMBER_TABLE
    , p1_a46 JTF_NUMBER_TABLE
    , p1_a47 JTF_NUMBER_TABLE
    , p1_a48 JTF_NUMBER_TABLE
    , p1_a49 JTF_NUMBER_TABLE
    , p1_a50 JTF_NUMBER_TABLE
    , p1_a51 JTF_NUMBER_TABLE
    , p1_a52 JTF_NUMBER_TABLE
    , p1_a53 JTF_NUMBER_TABLE
    , p1_a54 JTF_NUMBER_TABLE
    , p1_a55 JTF_NUMBER_TABLE
    , p1_a56 JTF_NUMBER_TABLE
    , p1_a57 JTF_DATE_TABLE
    , p1_a58 JTF_DATE_TABLE
    , p1_a59 JTF_DATE_TABLE
    , p1_a60 JTF_DATE_TABLE
    , p1_a61 JTF_NUMBER_TABLE
    , p1_a62 JTF_NUMBER_TABLE
    , p1_a63 JTF_NUMBER_TABLE
    , p1_a64 JTF_NUMBER_TABLE
    , p1_a65 JTF_NUMBER_TABLE
    , p1_a66 JTF_NUMBER_TABLE
    , p1_a67 JTF_NUMBER_TABLE
    , p1_a68 JTF_VARCHAR2_TABLE_100
    , p1_a69 JTF_DATE_TABLE
    , p1_a70 JTF_NUMBER_TABLE
    , p1_a71 JTF_NUMBER_TABLE
    , p1_a72 JTF_NUMBER_TABLE
    , p1_a73 JTF_NUMBER_TABLE
    , p1_a74 JTF_NUMBER_TABLE
    , p1_a75 JTF_VARCHAR2_TABLE_100
    , p1_a76 JTF_NUMBER_TABLE
    , p1_a77 JTF_VARCHAR2_TABLE_100
    , p1_a78 JTF_VARCHAR2_TABLE_100
    , p1_a79 JTF_VARCHAR2_TABLE_200
    , p1_a80 JTF_VARCHAR2_TABLE_200
    , p1_a81 JTF_VARCHAR2_TABLE_200
    , p1_a82 JTF_VARCHAR2_TABLE_200
    , p1_a83 JTF_VARCHAR2_TABLE_200
    , p1_a84 JTF_VARCHAR2_TABLE_200
    , p1_a85 JTF_VARCHAR2_TABLE_200
    , p1_a86 JTF_VARCHAR2_TABLE_200
    , p1_a87 JTF_VARCHAR2_TABLE_200
    , p1_a88 JTF_VARCHAR2_TABLE_200
    , p1_a89 JTF_VARCHAR2_TABLE_200
    , p1_a90 JTF_VARCHAR2_TABLE_200
    , p1_a91 JTF_VARCHAR2_TABLE_200
    , p1_a92 JTF_VARCHAR2_TABLE_200
    , p1_a93 JTF_VARCHAR2_TABLE_200
    , p1_a94 JTF_VARCHAR2_TABLE_100
    , p1_a95 JTF_VARCHAR2_TABLE_100
    , p1_a96 JTF_NUMBER_TABLE
    , p1_a97 JTF_DATE_TABLE
    , p1_a98 JTF_DATE_TABLE
    , p1_a99 JTF_NUMBER_TABLE
    , p1_a100 JTF_NUMBER_TABLE
    , p1_a101 JTF_NUMBER_TABLE
    , p1_a102 JTF_NUMBER_TABLE
    , p1_a103 JTF_NUMBER_TABLE
    , p1_a104 JTF_NUMBER_TABLE
    , p1_a105 JTF_VARCHAR2_TABLE_100
    , p1_a106 JTF_VARCHAR2_TABLE_100
    , p1_a107 JTF_VARCHAR2_TABLE_100
    , p1_a108 JTF_NUMBER_TABLE
    , p1_a109 JTF_VARCHAR2_TABLE_100
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_NUMBER_TABLE
    , p2_a8 JTF_NUMBER_TABLE
    , p2_a9 JTF_NUMBER_TABLE
    , p2_a10 JTF_NUMBER_TABLE
    , p2_a11 JTF_NUMBER_TABLE
    , p2_a12 JTF_NUMBER_TABLE
    , p2_a13 JTF_VARCHAR2_TABLE_100
    , p2_a14 JTF_VARCHAR2_TABLE_100
    , p2_a15 JTF_NUMBER_TABLE
    , p2_a16 JTF_NUMBER_TABLE
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_300
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_NUMBER_TABLE
    , p3_a13 JTF_VARCHAR2_TABLE_100
    , p3_a14 JTF_DATE_TABLE
    , p3_a15 JTF_DATE_TABLE
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_VARCHAR2_TABLE_200
    , p3_a18 JTF_VARCHAR2_TABLE_200
    , p3_a19 JTF_VARCHAR2_TABLE_200
    , p3_a20 JTF_VARCHAR2_TABLE_200
    , p3_a21 JTF_VARCHAR2_TABLE_200
    , p3_a22 JTF_VARCHAR2_TABLE_200
    , p3_a23 JTF_VARCHAR2_TABLE_200
    , p3_a24 JTF_VARCHAR2_TABLE_200
    , p3_a25 JTF_VARCHAR2_TABLE_200
    , p3_a26 JTF_VARCHAR2_TABLE_200
    , p3_a27 JTF_VARCHAR2_TABLE_200
    , p3_a28 JTF_VARCHAR2_TABLE_200
    , p3_a29 JTF_VARCHAR2_TABLE_200
    , p3_a30 JTF_VARCHAR2_TABLE_200
    , p3_a31 JTF_VARCHAR2_TABLE_200
    , p3_a32 JTF_VARCHAR2_TABLE_4000
    , p3_a33 JTF_NUMBER_TABLE
    , p3_a34 JTF_NUMBER_TABLE
    , p3_a35 JTF_NUMBER_TABLE
    , p3_a36 JTF_VARCHAR2_TABLE_100
    , p3_a37 JTF_NUMBER_TABLE
    , p3_a38 JTF_NUMBER_TABLE
    , p3_a39 JTF_NUMBER_TABLE
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_NUMBER_TABLE
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_DATE_TABLE
    , p4_a21 JTF_DATE_TABLE
    , p4_a22 JTF_NUMBER_TABLE
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_VARCHAR2_TABLE_200
    , p4_a36 JTF_VARCHAR2_TABLE_200
    , p4_a37 JTF_VARCHAR2_TABLE_200
    , p4_a38 JTF_VARCHAR2_TABLE_200
    , p4_a39 JTF_VARCHAR2_TABLE_200
    , p4_a40 JTF_VARCHAR2_TABLE_200
    , p4_a41 JTF_NUMBER_TABLE
    , p4_a42 JTF_NUMBER_TABLE
    , p4_a43 JTF_NUMBER_TABLE
    , p4_a44 JTF_NUMBER_TABLE
    , p4_a45 JTF_DATE_TABLE
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p4_a47 JTF_NUMBER_TABLE
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_DATE_TABLE
    , p6_a8 JTF_DATE_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_DATE_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_VARCHAR2_TABLE_100
    , p6_a19 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_DATE_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_VARCHAR2_TABLE_300
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , p7_a31 JTF_VARCHAR2_TABLE_200
    , p7_a32 JTF_VARCHAR2_TABLE_200
    , p7_a33 JTF_VARCHAR2_TABLE_200
    , p7_a34 JTF_VARCHAR2_TABLE_200
    , p7_a35 JTF_VARCHAR2_TABLE_200
    , p7_a36 JTF_VARCHAR2_TABLE_200
    , p7_a37 JTF_VARCHAR2_TABLE_200
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_300
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_NUMBER_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_NUMBER_TABLE
    , p7_a45 JTF_DATE_TABLE
    , p7_a46 JTF_VARCHAR2_TABLE_100
    , p7_a47 JTF_NUMBER_TABLE
    , p7_a48 JTF_VARCHAR2_TABLE_100
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_300
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_NUMBER_TABLE
    , p8_a10 JTF_VARCHAR2_TABLE_300
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_VARCHAR2_TABLE_100
    , p8_a17 JTF_VARCHAR2_TABLE_100
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_VARCHAR2_TABLE_100
    , p8_a20 JTF_NUMBER_TABLE
    , p8_a21 JTF_NUMBER_TABLE
    , p8_a22 JTF_VARCHAR2_TABLE_100
    , p8_a23 JTF_DATE_TABLE
    , p8_a24 JTF_VARCHAR2_TABLE_100
    , p8_a25 JTF_VARCHAR2_TABLE_200
    , p8_a26 JTF_VARCHAR2_TABLE_200
    , p8_a27 JTF_VARCHAR2_TABLE_200
    , p8_a28 JTF_VARCHAR2_TABLE_200
    , p8_a29 JTF_VARCHAR2_TABLE_200
    , p8_a30 JTF_VARCHAR2_TABLE_200
    , p8_a31 JTF_VARCHAR2_TABLE_200
    , p8_a32 JTF_VARCHAR2_TABLE_200
    , p8_a33 JTF_VARCHAR2_TABLE_200
    , p8_a34 JTF_VARCHAR2_TABLE_200
    , p8_a35 JTF_VARCHAR2_TABLE_200
    , p8_a36 JTF_VARCHAR2_TABLE_200
    , p8_a37 JTF_VARCHAR2_TABLE_200
    , p8_a38 JTF_VARCHAR2_TABLE_200
    , p8_a39 JTF_VARCHAR2_TABLE_200
    , p8_a40 JTF_NUMBER_TABLE
    , p8_a41 JTF_NUMBER_TABLE
    , p8_a42 JTF_DATE_TABLE
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_VARCHAR2_TABLE_100
    , p8_a45 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_VARCHAR2_TABLE_300
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_VARCHAR2_TABLE_300
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_VARCHAR2_TABLE_200
    , p9_a12 JTF_VARCHAR2_TABLE_200
    , p9_a13 JTF_VARCHAR2_TABLE_200
    , p9_a14 JTF_VARCHAR2_TABLE_200
    , p9_a15 JTF_VARCHAR2_TABLE_200
    , p9_a16 JTF_VARCHAR2_TABLE_200
    , p9_a17 JTF_VARCHAR2_TABLE_200
    , p9_a18 JTF_VARCHAR2_TABLE_200
    , p9_a19 JTF_VARCHAR2_TABLE_200
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_NUMBER_TABLE
    , p9_a27 JTF_NUMBER_TABLE
    , p9_a28 JTF_DATE_TABLE
    , p9_a29 JTF_NUMBER_TABLE
    , p9_a30 JTF_NUMBER_TABLE
    , p9_a31 JTF_NUMBER_TABLE
    , p9_a32 JTF_VARCHAR2_TABLE_100
    , p9_a33 JTF_NUMBER_TABLE
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_DATE_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_VARCHAR2_TABLE_300
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_NUMBER_TABLE
    , p10_a10 JTF_VARCHAR2_TABLE_300
    , p10_a11 JTF_VARCHAR2_TABLE_100
    , p10_a12 JTF_NUMBER_TABLE
    , p10_a13 JTF_NUMBER_TABLE
    , p10_a14 JTF_DATE_TABLE
    , p10_a15 JTF_DATE_TABLE
    , p10_a16 JTF_NUMBER_TABLE
    , p10_a17 JTF_NUMBER_TABLE
    , p10_a18 JTF_NUMBER_TABLE
    , p10_a19 JTF_NUMBER_TABLE
    , p10_a20 JTF_VARCHAR2_TABLE_100
    , p10_a21 JTF_VARCHAR2_TABLE_100
    , p10_a22 JTF_VARCHAR2_TABLE_100
    , p10_a23 JTF_VARCHAR2_TABLE_100
    , p10_a24 JTF_VARCHAR2_TABLE_100
    , p10_a25 JTF_NUMBER_TABLE
    , p10_a26 JTF_VARCHAR2_TABLE_100
    , p10_a27 JTF_DATE_TABLE
    , p10_a28 JTF_DATE_TABLE
    , p10_a29 JTF_VARCHAR2_TABLE_100
    , p10_a30 JTF_VARCHAR2_TABLE_200
    , p10_a31 JTF_VARCHAR2_TABLE_200
    , p10_a32 JTF_VARCHAR2_TABLE_200
    , p10_a33 JTF_VARCHAR2_TABLE_200
    , p10_a34 JTF_VARCHAR2_TABLE_200
    , p10_a35 JTF_VARCHAR2_TABLE_200
    , p10_a36 JTF_VARCHAR2_TABLE_200
    , p10_a37 JTF_VARCHAR2_TABLE_200
    , p10_a38 JTF_VARCHAR2_TABLE_200
    , p10_a39 JTF_VARCHAR2_TABLE_200
    , p10_a40 JTF_VARCHAR2_TABLE_200
    , p10_a41 JTF_VARCHAR2_TABLE_200
    , p10_a42 JTF_VARCHAR2_TABLE_200
    , p10_a43 JTF_VARCHAR2_TABLE_200
    , p10_a44 JTF_VARCHAR2_TABLE_200
    , p10_a45 JTF_NUMBER_TABLE
    , p10_a46 JTF_DATE_TABLE
    , p10_a47 JTF_NUMBER_TABLE
    , p10_a48 JTF_NUMBER_TABLE
    , p10_a49 JTF_VARCHAR2_TABLE_100
    , p10_a50 JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_DATE_TABLE
    , p11_a8 JTF_DATE_TABLE
    , p11_a9 JTF_VARCHAR2_TABLE_100
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_VARCHAR2_TABLE_100
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p11_a13 JTF_VARCHAR2_TABLE_200
    , p11_a14 JTF_VARCHAR2_TABLE_200
    , p11_a15 JTF_VARCHAR2_TABLE_200
    , p11_a16 JTF_VARCHAR2_TABLE_200
    , p11_a17 JTF_VARCHAR2_TABLE_200
    , p11_a18 JTF_VARCHAR2_TABLE_200
    , p11_a19 JTF_VARCHAR2_TABLE_200
    , p11_a20 JTF_VARCHAR2_TABLE_200
    , p11_a21 JTF_VARCHAR2_TABLE_200
    , p11_a22 JTF_VARCHAR2_TABLE_200
    , p11_a23 JTF_VARCHAR2_TABLE_200
    , p11_a24 JTF_VARCHAR2_TABLE_200
    , p11_a25 JTF_VARCHAR2_TABLE_200
    , p11_a26 JTF_VARCHAR2_TABLE_200
    , p11_a27 JTF_VARCHAR2_TABLE_200
    , p11_a28 JTF_VARCHAR2_TABLE_200
    , p11_a29 JTF_VARCHAR2_TABLE_200
    , p11_a30 JTF_VARCHAR2_TABLE_200
    , p11_a31 JTF_VARCHAR2_TABLE_200
    , p11_a32 JTF_VARCHAR2_TABLE_200
    , p11_a33 JTF_VARCHAR2_TABLE_200
    , p11_a34 JTF_VARCHAR2_TABLE_200
    , p11_a35 JTF_VARCHAR2_TABLE_200
    , p11_a36 JTF_VARCHAR2_TABLE_200
    , p11_a37 JTF_VARCHAR2_TABLE_200
    , p11_a38 JTF_VARCHAR2_TABLE_200
    , p11_a39 JTF_VARCHAR2_TABLE_200
    , p11_a40 JTF_VARCHAR2_TABLE_200
    , p11_a41 JTF_VARCHAR2_TABLE_200
    , p11_a42 JTF_VARCHAR2_TABLE_200
    , p11_a43 JTF_NUMBER_TABLE
    , p11_a44 JTF_VARCHAR2_TABLE_100
    , p11_a45 JTF_VARCHAR2_TABLE_100
    , p11_a46 JTF_VARCHAR2_TABLE_100
    , p11_a47 JTF_NUMBER_TABLE
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_NUMBER_TABLE
    , p12_a4 JTF_NUMBER_TABLE
    , p12_a5 JTF_NUMBER_TABLE
    , p12_a6 JTF_VARCHAR2_TABLE_300
    , p12_a7 JTF_DATE_TABLE
    , p12_a8 JTF_VARCHAR2_TABLE_100
    , p12_a9 JTF_VARCHAR2_TABLE_100
    , p12_a10 JTF_VARCHAR2_TABLE_200
    , p12_a11 JTF_VARCHAR2_TABLE_200
    , p12_a12 JTF_VARCHAR2_TABLE_200
    , p12_a13 JTF_VARCHAR2_TABLE_200
    , p12_a14 JTF_VARCHAR2_TABLE_200
    , p12_a15 JTF_VARCHAR2_TABLE_200
    , p12_a16 JTF_VARCHAR2_TABLE_200
    , p12_a17 JTF_VARCHAR2_TABLE_200
    , p12_a18 JTF_VARCHAR2_TABLE_200
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_200
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_200
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_200
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_NUMBER_TABLE
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_NUMBER_TABLE
    , p13_a3 JTF_NUMBER_TABLE
    , p13_a4 JTF_NUMBER_TABLE
    , p13_a5 JTF_NUMBER_TABLE
    , p13_a6 JTF_NUMBER_TABLE
    , p13_a7 JTF_NUMBER_TABLE
    , p13_a8 JTF_VARCHAR2_TABLE_100
    , p13_a9 JTF_NUMBER_TABLE
    , p13_a10 JTF_VARCHAR2_TABLE_100
    , p13_a11 JTF_NUMBER_TABLE
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_NUMBER_TABLE
    , p14_a2 JTF_NUMBER_TABLE
    , p14_a3 JTF_NUMBER_TABLE
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_NUMBER_TABLE
    , p14_a8 JTF_VARCHAR2_TABLE_100
    , p14_a9 JTF_NUMBER_TABLE
    , p_prev_activity_id  NUMBER
    , p_failure_id  NUMBER
    , p_failure_date  DATE
    , p_failure_entry_id  NUMBER
    , p_failure_code  VARCHAR2
    , p_cause_code  VARCHAR2
    , p_resolution_code  VARCHAR2
    , p_failure_comments  VARCHAR2
    , p_failure_code_required  VARCHAR2
    , x_wip_entity_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_eam_wo_tbl eam_process_wo_pub.eam_wo_tbl_type;
    ddp_eam_wo_relations_tbl eam_process_wo_pub.eam_wo_relations_tbl_type;
    ddp_eam_op_tbl eam_process_wo_pub.eam_op_tbl_type;
    ddp_eam_res_tbl eam_process_wo_pub.eam_res_tbl_type;
    ddp_eam_res_inst_tbl eam_process_wo_pub.eam_res_inst_tbl_type;
    ddp_eam_res_usage_tbl eam_process_wo_pub.eam_res_usage_tbl_type;
    ddp_eam_mat_req_tbl eam_process_wo_pub.eam_mat_req_tbl_type;
    ddp_eam_direct_items_tbl eam_process_wo_pub.eam_direct_items_tbl_type;
    ddp_eam_request_tbl eam_process_wo_pub.eam_request_tbl_type;
    ddp_eam_wo_comp_tbl eam_process_wo_pub.eam_wo_comp_tbl_type;
    ddp_eam_meter_reading_tbl eam_process_wo_pub.eam_meter_reading_tbl_type;
    ddp_eam_counter_prop_tbl eam_process_wo_pub.eam_counter_prop_tbl_type;
    ddp_eam_wo_comp_rebuild_tbl eam_process_wo_pub.eam_wo_comp_rebuild_tbl_type;
    ddp_eam_wo_comp_mr_read_tbl eam_process_wo_pub.eam_wo_comp_mr_read_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    eam_process_wo_pub_w.rosetta_table_copy_in_p27(ddp_eam_wo_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      , p1_a20
      , p1_a21
      , p1_a22
      , p1_a23
      , p1_a24
      , p1_a25
      , p1_a26
      , p1_a27
      , p1_a28
      , p1_a29
      , p1_a30
      , p1_a31
      , p1_a32
      , p1_a33
      , p1_a34
      , p1_a35
      , p1_a36
      , p1_a37
      , p1_a38
      , p1_a39
      , p1_a40
      , p1_a41
      , p1_a42
      , p1_a43
      , p1_a44
      , p1_a45
      , p1_a46
      , p1_a47
      , p1_a48
      , p1_a49
      , p1_a50
      , p1_a51
      , p1_a52
      , p1_a53
      , p1_a54
      , p1_a55
      , p1_a56
      , p1_a57
      , p1_a58
      , p1_a59
      , p1_a60
      , p1_a61
      , p1_a62
      , p1_a63
      , p1_a64
      , p1_a65
      , p1_a66
      , p1_a67
      , p1_a68
      , p1_a69
      , p1_a70
      , p1_a71
      , p1_a72
      , p1_a73
      , p1_a74
      , p1_a75
      , p1_a76
      , p1_a77
      , p1_a78
      , p1_a79
      , p1_a80
      , p1_a81
      , p1_a82
      , p1_a83
      , p1_a84
      , p1_a85
      , p1_a86
      , p1_a87
      , p1_a88
      , p1_a89
      , p1_a90
      , p1_a91
      , p1_a92
      , p1_a93
      , p1_a94
      , p1_a95
      , p1_a96
      , p1_a97
      , p1_a98
      , p1_a99
      , p1_a100
      , p1_a101
      , p1_a102
      , p1_a103
      , p1_a104
      , p1_a105
      , p1_a106
      , p1_a107
      , p1_a108
      , p1_a109
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p25(ddp_eam_wo_relations_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p28(ddp_eam_op_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      , p3_a34
      , p3_a35
      , p3_a36
      , p3_a37
      , p3_a38
      , p3_a39
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p30(ddp_eam_res_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p31(ddp_eam_res_inst_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p33(ddp_eam_res_usage_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p34(ddp_eam_mat_req_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p35(ddp_eam_direct_items_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p43(ddp_eam_request_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p36(ddp_eam_wo_comp_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p38(ddp_eam_meter_reading_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      , p11_a43
      , p11_a44
      , p11_a45
      , p11_a46
      , p11_a47
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p39(ddp_eam_counter_prop_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p41(ddp_eam_wo_comp_rebuild_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p42(ddp_eam_wo_comp_mr_read_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      );













    -- here's the delegated call to the old PL/SQL routine
    eam_createupdate_wo_pvt.create_update_wo(p_commit,
      ddp_eam_wo_tbl,
      ddp_eam_wo_relations_tbl,
      ddp_eam_op_tbl,
      ddp_eam_res_tbl,
      ddp_eam_res_inst_tbl,
      ddp_eam_res_usage_tbl,
      ddp_eam_mat_req_tbl,
      ddp_eam_direct_items_tbl,
      ddp_eam_request_tbl,
      ddp_eam_wo_comp_tbl,
      ddp_eam_meter_reading_tbl,
      ddp_eam_counter_prop_tbl,
      ddp_eam_wo_comp_rebuild_tbl,
      ddp_eam_wo_comp_mr_read_tbl,
      p_prev_activity_id,
      p_failure_id,
      p_failure_date,
      p_failure_entry_id,
      p_failure_code,
      p_cause_code,
      p_resolution_code,
      p_failure_comments,
      p_failure_code_required,
      x_wip_entity_id,
      x_return_status,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any


























  end;

  procedure create_update_wo(p_commit  VARCHAR2
    , p1_a0 JTF_NUMBER_TABLE
    , p1_a1 JTF_NUMBER_TABLE
    , p1_a2 JTF_NUMBER_TABLE
    , p1_a3 JTF_VARCHAR2_TABLE_300
    , p1_a4 JTF_NUMBER_TABLE
    , p1_a5 JTF_NUMBER_TABLE
    , p1_a6 JTF_VARCHAR2_TABLE_300
    , p1_a7 JTF_VARCHAR2_TABLE_100
    , p1_a8 JTF_NUMBER_TABLE
    , p1_a9 JTF_NUMBER_TABLE
    , p1_a10 JTF_VARCHAR2_TABLE_100
    , p1_a11 JTF_NUMBER_TABLE
    , p1_a12 JTF_NUMBER_TABLE
    , p1_a13 JTF_NUMBER_TABLE
    , p1_a14 JTF_NUMBER_TABLE
    , p1_a15 JTF_VARCHAR2_TABLE_100
    , p1_a16 JTF_NUMBER_TABLE
    , p1_a17 JTF_VARCHAR2_TABLE_100
    , p1_a18 JTF_VARCHAR2_TABLE_100
    , p1_a19 JTF_VARCHAR2_TABLE_100
    , p1_a20 JTF_VARCHAR2_TABLE_100
    , p1_a21 JTF_NUMBER_TABLE
    , p1_a22 JTF_NUMBER_TABLE
    , p1_a23 JTF_DATE_TABLE
    , p1_a24 JTF_NUMBER_TABLE
    , p1_a25 JTF_NUMBER_TABLE
    , p1_a26 JTF_DATE_TABLE
    , p1_a27 JTF_DATE_TABLE
    , p1_a28 JTF_VARCHAR2_TABLE_100
    , p1_a29 JTF_NUMBER_TABLE
    , p1_a30 JTF_VARCHAR2_TABLE_100
    , p1_a31 JTF_VARCHAR2_TABLE_100
    , p1_a32 JTF_VARCHAR2_TABLE_100
    , p1_a33 JTF_NUMBER_TABLE
    , p1_a34 JTF_NUMBER_TABLE
    , p1_a35 JTF_VARCHAR2_TABLE_100
    , p1_a36 JTF_NUMBER_TABLE
    , p1_a37 JTF_DATE_TABLE
    , p1_a38 JTF_DATE_TABLE
    , p1_a39 JTF_VARCHAR2_TABLE_100
    , p1_a40 JTF_VARCHAR2_TABLE_100
    , p1_a41 JTF_VARCHAR2_TABLE_100
    , p1_a42 JTF_VARCHAR2_TABLE_100
    , p1_a43 JTF_NUMBER_TABLE
    , p1_a44 JTF_VARCHAR2_TABLE_100
    , p1_a45 JTF_NUMBER_TABLE
    , p1_a46 JTF_NUMBER_TABLE
    , p1_a47 JTF_NUMBER_TABLE
    , p1_a48 JTF_NUMBER_TABLE
    , p1_a49 JTF_NUMBER_TABLE
    , p1_a50 JTF_NUMBER_TABLE
    , p1_a51 JTF_NUMBER_TABLE
    , p1_a52 JTF_NUMBER_TABLE
    , p1_a53 JTF_NUMBER_TABLE
    , p1_a54 JTF_NUMBER_TABLE
    , p1_a55 JTF_NUMBER_TABLE
    , p1_a56 JTF_NUMBER_TABLE
    , p1_a57 JTF_DATE_TABLE
    , p1_a58 JTF_DATE_TABLE
    , p1_a59 JTF_DATE_TABLE
    , p1_a60 JTF_DATE_TABLE
    , p1_a61 JTF_NUMBER_TABLE
    , p1_a62 JTF_NUMBER_TABLE
    , p1_a63 JTF_NUMBER_TABLE
    , p1_a64 JTF_NUMBER_TABLE
    , p1_a65 JTF_NUMBER_TABLE
    , p1_a66 JTF_NUMBER_TABLE
    , p1_a67 JTF_NUMBER_TABLE
    , p1_a68 JTF_VARCHAR2_TABLE_100
    , p1_a69 JTF_DATE_TABLE
    , p1_a70 JTF_NUMBER_TABLE
    , p1_a71 JTF_NUMBER_TABLE
    , p1_a72 JTF_NUMBER_TABLE
    , p1_a73 JTF_NUMBER_TABLE
    , p1_a74 JTF_NUMBER_TABLE
    , p1_a75 JTF_VARCHAR2_TABLE_100
    , p1_a76 JTF_NUMBER_TABLE
    , p1_a77 JTF_VARCHAR2_TABLE_100
    , p1_a78 JTF_VARCHAR2_TABLE_100
    , p1_a79 JTF_VARCHAR2_TABLE_200
    , p1_a80 JTF_VARCHAR2_TABLE_200
    , p1_a81 JTF_VARCHAR2_TABLE_200
    , p1_a82 JTF_VARCHAR2_TABLE_200
    , p1_a83 JTF_VARCHAR2_TABLE_200
    , p1_a84 JTF_VARCHAR2_TABLE_200
    , p1_a85 JTF_VARCHAR2_TABLE_200
    , p1_a86 JTF_VARCHAR2_TABLE_200
    , p1_a87 JTF_VARCHAR2_TABLE_200
    , p1_a88 JTF_VARCHAR2_TABLE_200
    , p1_a89 JTF_VARCHAR2_TABLE_200
    , p1_a90 JTF_VARCHAR2_TABLE_200
    , p1_a91 JTF_VARCHAR2_TABLE_200
    , p1_a92 JTF_VARCHAR2_TABLE_200
    , p1_a93 JTF_VARCHAR2_TABLE_200
    , p1_a94 JTF_VARCHAR2_TABLE_100
    , p1_a95 JTF_VARCHAR2_TABLE_100
    , p1_a96 JTF_NUMBER_TABLE
    , p1_a97 JTF_DATE_TABLE
    , p1_a98 JTF_DATE_TABLE
    , p1_a99 JTF_NUMBER_TABLE
    , p1_a100 JTF_NUMBER_TABLE
    , p1_a101 JTF_NUMBER_TABLE
    , p1_a102 JTF_NUMBER_TABLE
    , p1_a103 JTF_NUMBER_TABLE
    , p1_a104 JTF_NUMBER_TABLE
    , p1_a105 JTF_VARCHAR2_TABLE_100
    , p1_a106 JTF_VARCHAR2_TABLE_100
    , p1_a107 JTF_VARCHAR2_TABLE_100
    , p1_a108 JTF_NUMBER_TABLE
    , p1_a109 JTF_VARCHAR2_TABLE_100
    , p2_a0 JTF_NUMBER_TABLE
    , p2_a1 JTF_NUMBER_TABLE
    , p2_a2 JTF_NUMBER_TABLE
    , p2_a3 JTF_NUMBER_TABLE
    , p2_a4 JTF_NUMBER_TABLE
    , p2_a5 JTF_NUMBER_TABLE
    , p2_a6 JTF_NUMBER_TABLE
    , p2_a7 JTF_NUMBER_TABLE
    , p2_a8 JTF_NUMBER_TABLE
    , p2_a9 JTF_NUMBER_TABLE
    , p2_a10 JTF_NUMBER_TABLE
    , p2_a11 JTF_NUMBER_TABLE
    , p2_a12 JTF_NUMBER_TABLE
    , p2_a13 JTF_VARCHAR2_TABLE_100
    , p2_a14 JTF_VARCHAR2_TABLE_100
    , p2_a15 JTF_NUMBER_TABLE
    , p2_a16 JTF_NUMBER_TABLE
    , p3_a0 JTF_NUMBER_TABLE
    , p3_a1 JTF_NUMBER_TABLE
    , p3_a2 JTF_NUMBER_TABLE
    , p3_a3 JTF_NUMBER_TABLE
    , p3_a4 JTF_NUMBER_TABLE
    , p3_a5 JTF_NUMBER_TABLE
    , p3_a6 JTF_NUMBER_TABLE
    , p3_a7 JTF_NUMBER_TABLE
    , p3_a8 JTF_NUMBER_TABLE
    , p3_a9 JTF_VARCHAR2_TABLE_300
    , p3_a10 JTF_NUMBER_TABLE
    , p3_a11 JTF_NUMBER_TABLE
    , p3_a12 JTF_NUMBER_TABLE
    , p3_a13 JTF_VARCHAR2_TABLE_100
    , p3_a14 JTF_DATE_TABLE
    , p3_a15 JTF_DATE_TABLE
    , p3_a16 JTF_VARCHAR2_TABLE_100
    , p3_a17 JTF_VARCHAR2_TABLE_200
    , p3_a18 JTF_VARCHAR2_TABLE_200
    , p3_a19 JTF_VARCHAR2_TABLE_200
    , p3_a20 JTF_VARCHAR2_TABLE_200
    , p3_a21 JTF_VARCHAR2_TABLE_200
    , p3_a22 JTF_VARCHAR2_TABLE_200
    , p3_a23 JTF_VARCHAR2_TABLE_200
    , p3_a24 JTF_VARCHAR2_TABLE_200
    , p3_a25 JTF_VARCHAR2_TABLE_200
    , p3_a26 JTF_VARCHAR2_TABLE_200
    , p3_a27 JTF_VARCHAR2_TABLE_200
    , p3_a28 JTF_VARCHAR2_TABLE_200
    , p3_a29 JTF_VARCHAR2_TABLE_200
    , p3_a30 JTF_VARCHAR2_TABLE_200
    , p3_a31 JTF_VARCHAR2_TABLE_200
    , p3_a32 JTF_VARCHAR2_TABLE_4000
    , p3_a33 JTF_NUMBER_TABLE
    , p3_a34 JTF_NUMBER_TABLE
    , p3_a35 JTF_NUMBER_TABLE
    , p3_a36 JTF_VARCHAR2_TABLE_100
    , p3_a37 JTF_NUMBER_TABLE
    , p3_a38 JTF_NUMBER_TABLE
    , p3_a39 JTF_NUMBER_TABLE
    , p4_a0 JTF_NUMBER_TABLE
    , p4_a1 JTF_NUMBER_TABLE
    , p4_a2 JTF_NUMBER_TABLE
    , p4_a3 JTF_NUMBER_TABLE
    , p4_a4 JTF_NUMBER_TABLE
    , p4_a5 JTF_NUMBER_TABLE
    , p4_a6 JTF_NUMBER_TABLE
    , p4_a7 JTF_NUMBER_TABLE
    , p4_a8 JTF_VARCHAR2_TABLE_100
    , p4_a9 JTF_NUMBER_TABLE
    , p4_a10 JTF_NUMBER_TABLE
    , p4_a11 JTF_NUMBER_TABLE
    , p4_a12 JTF_NUMBER_TABLE
    , p4_a13 JTF_NUMBER_TABLE
    , p4_a14 JTF_NUMBER_TABLE
    , p4_a15 JTF_NUMBER_TABLE
    , p4_a16 JTF_NUMBER_TABLE
    , p4_a17 JTF_NUMBER_TABLE
    , p4_a18 JTF_NUMBER_TABLE
    , p4_a19 JTF_NUMBER_TABLE
    , p4_a20 JTF_DATE_TABLE
    , p4_a21 JTF_DATE_TABLE
    , p4_a22 JTF_NUMBER_TABLE
    , p4_a23 JTF_NUMBER_TABLE
    , p4_a24 JTF_NUMBER_TABLE
    , p4_a25 JTF_VARCHAR2_TABLE_100
    , p4_a26 JTF_VARCHAR2_TABLE_200
    , p4_a27 JTF_VARCHAR2_TABLE_200
    , p4_a28 JTF_VARCHAR2_TABLE_200
    , p4_a29 JTF_VARCHAR2_TABLE_200
    , p4_a30 JTF_VARCHAR2_TABLE_200
    , p4_a31 JTF_VARCHAR2_TABLE_200
    , p4_a32 JTF_VARCHAR2_TABLE_200
    , p4_a33 JTF_VARCHAR2_TABLE_200
    , p4_a34 JTF_VARCHAR2_TABLE_200
    , p4_a35 JTF_VARCHAR2_TABLE_200
    , p4_a36 JTF_VARCHAR2_TABLE_200
    , p4_a37 JTF_VARCHAR2_TABLE_200
    , p4_a38 JTF_VARCHAR2_TABLE_200
    , p4_a39 JTF_VARCHAR2_TABLE_200
    , p4_a40 JTF_VARCHAR2_TABLE_200
    , p4_a41 JTF_NUMBER_TABLE
    , p4_a42 JTF_NUMBER_TABLE
    , p4_a43 JTF_NUMBER_TABLE
    , p4_a44 JTF_NUMBER_TABLE
    , p4_a45 JTF_DATE_TABLE
    , p4_a46 JTF_VARCHAR2_TABLE_100
    , p4_a47 JTF_NUMBER_TABLE
    , p5_a0 JTF_NUMBER_TABLE
    , p5_a1 JTF_NUMBER_TABLE
    , p5_a2 JTF_NUMBER_TABLE
    , p5_a3 JTF_NUMBER_TABLE
    , p5_a4 JTF_NUMBER_TABLE
    , p5_a5 JTF_NUMBER_TABLE
    , p5_a6 JTF_NUMBER_TABLE
    , p5_a7 JTF_NUMBER_TABLE
    , p5_a8 JTF_VARCHAR2_TABLE_100
    , p5_a9 JTF_DATE_TABLE
    , p5_a10 JTF_DATE_TABLE
    , p5_a11 JTF_NUMBER_TABLE
    , p5_a12 JTF_VARCHAR2_TABLE_100
    , p5_a13 JTF_NUMBER_TABLE
    , p6_a0 JTF_NUMBER_TABLE
    , p6_a1 JTF_NUMBER_TABLE
    , p6_a2 JTF_NUMBER_TABLE
    , p6_a3 JTF_NUMBER_TABLE
    , p6_a4 JTF_NUMBER_TABLE
    , p6_a5 JTF_NUMBER_TABLE
    , p6_a6 JTF_NUMBER_TABLE
    , p6_a7 JTF_DATE_TABLE
    , p6_a8 JTF_DATE_TABLE
    , p6_a9 JTF_DATE_TABLE
    , p6_a10 JTF_DATE_TABLE
    , p6_a11 JTF_NUMBER_TABLE
    , p6_a12 JTF_NUMBER_TABLE
    , p6_a13 JTF_NUMBER_TABLE
    , p6_a14 JTF_NUMBER_TABLE
    , p6_a15 JTF_DATE_TABLE
    , p6_a16 JTF_NUMBER_TABLE
    , p6_a17 JTF_VARCHAR2_TABLE_100
    , p6_a18 JTF_VARCHAR2_TABLE_100
    , p6_a19 JTF_NUMBER_TABLE
    , p7_a0 JTF_NUMBER_TABLE
    , p7_a1 JTF_NUMBER_TABLE
    , p7_a2 JTF_NUMBER_TABLE
    , p7_a3 JTF_NUMBER_TABLE
    , p7_a4 JTF_NUMBER_TABLE
    , p7_a5 JTF_NUMBER_TABLE
    , p7_a6 JTF_NUMBER_TABLE
    , p7_a7 JTF_NUMBER_TABLE
    , p7_a8 JTF_NUMBER_TABLE
    , p7_a9 JTF_NUMBER_TABLE
    , p7_a10 JTF_DATE_TABLE
    , p7_a11 JTF_NUMBER_TABLE
    , p7_a12 JTF_NUMBER_TABLE
    , p7_a13 JTF_NUMBER_TABLE
    , p7_a14 JTF_NUMBER_TABLE
    , p7_a15 JTF_VARCHAR2_TABLE_100
    , p7_a16 JTF_NUMBER_TABLE
    , p7_a17 JTF_NUMBER_TABLE
    , p7_a18 JTF_NUMBER_TABLE
    , p7_a19 JTF_DATE_TABLE
    , p7_a20 JTF_NUMBER_TABLE
    , p7_a21 JTF_VARCHAR2_TABLE_300
    , p7_a22 JTF_VARCHAR2_TABLE_100
    , p7_a23 JTF_VARCHAR2_TABLE_200
    , p7_a24 JTF_VARCHAR2_TABLE_200
    , p7_a25 JTF_VARCHAR2_TABLE_200
    , p7_a26 JTF_VARCHAR2_TABLE_200
    , p7_a27 JTF_VARCHAR2_TABLE_200
    , p7_a28 JTF_VARCHAR2_TABLE_200
    , p7_a29 JTF_VARCHAR2_TABLE_200
    , p7_a30 JTF_VARCHAR2_TABLE_200
    , p7_a31 JTF_VARCHAR2_TABLE_200
    , p7_a32 JTF_VARCHAR2_TABLE_200
    , p7_a33 JTF_VARCHAR2_TABLE_200
    , p7_a34 JTF_VARCHAR2_TABLE_200
    , p7_a35 JTF_VARCHAR2_TABLE_200
    , p7_a36 JTF_VARCHAR2_TABLE_200
    , p7_a37 JTF_VARCHAR2_TABLE_200
    , p7_a38 JTF_VARCHAR2_TABLE_100
    , p7_a39 JTF_VARCHAR2_TABLE_300
    , p7_a40 JTF_NUMBER_TABLE
    , p7_a41 JTF_NUMBER_TABLE
    , p7_a42 JTF_NUMBER_TABLE
    , p7_a43 JTF_NUMBER_TABLE
    , p7_a44 JTF_NUMBER_TABLE
    , p7_a45 JTF_DATE_TABLE
    , p7_a46 JTF_VARCHAR2_TABLE_100
    , p7_a47 JTF_NUMBER_TABLE
    , p7_a48 JTF_VARCHAR2_TABLE_100
    , p8_a0 JTF_NUMBER_TABLE
    , p8_a1 JTF_NUMBER_TABLE
    , p8_a2 JTF_NUMBER_TABLE
    , p8_a3 JTF_VARCHAR2_TABLE_300
    , p8_a4 JTF_NUMBER_TABLE
    , p8_a5 JTF_NUMBER_TABLE
    , p8_a6 JTF_NUMBER_TABLE
    , p8_a7 JTF_NUMBER_TABLE
    , p8_a8 JTF_NUMBER_TABLE
    , p8_a9 JTF_NUMBER_TABLE
    , p8_a10 JTF_VARCHAR2_TABLE_300
    , p8_a11 JTF_NUMBER_TABLE
    , p8_a12 JTF_VARCHAR2_TABLE_100
    , p8_a13 JTF_NUMBER_TABLE
    , p8_a14 JTF_VARCHAR2_TABLE_100
    , p8_a15 JTF_NUMBER_TABLE
    , p8_a16 JTF_VARCHAR2_TABLE_100
    , p8_a17 JTF_VARCHAR2_TABLE_100
    , p8_a18 JTF_NUMBER_TABLE
    , p8_a19 JTF_VARCHAR2_TABLE_100
    , p8_a20 JTF_NUMBER_TABLE
    , p8_a21 JTF_NUMBER_TABLE
    , p8_a22 JTF_VARCHAR2_TABLE_100
    , p8_a23 JTF_DATE_TABLE
    , p8_a24 JTF_VARCHAR2_TABLE_100
    , p8_a25 JTF_VARCHAR2_TABLE_200
    , p8_a26 JTF_VARCHAR2_TABLE_200
    , p8_a27 JTF_VARCHAR2_TABLE_200
    , p8_a28 JTF_VARCHAR2_TABLE_200
    , p8_a29 JTF_VARCHAR2_TABLE_200
    , p8_a30 JTF_VARCHAR2_TABLE_200
    , p8_a31 JTF_VARCHAR2_TABLE_200
    , p8_a32 JTF_VARCHAR2_TABLE_200
    , p8_a33 JTF_VARCHAR2_TABLE_200
    , p8_a34 JTF_VARCHAR2_TABLE_200
    , p8_a35 JTF_VARCHAR2_TABLE_200
    , p8_a36 JTF_VARCHAR2_TABLE_200
    , p8_a37 JTF_VARCHAR2_TABLE_200
    , p8_a38 JTF_VARCHAR2_TABLE_200
    , p8_a39 JTF_VARCHAR2_TABLE_200
    , p8_a40 JTF_NUMBER_TABLE
    , p8_a41 JTF_NUMBER_TABLE
    , p8_a42 JTF_DATE_TABLE
    , p8_a43 JTF_NUMBER_TABLE
    , p8_a44 JTF_VARCHAR2_TABLE_100
    , p8_a45 JTF_NUMBER_TABLE
    , p9_a0 JTF_NUMBER_TABLE
    , p9_a1 JTF_NUMBER_TABLE
    , p9_a2 JTF_NUMBER_TABLE
    , p9_a3 JTF_NUMBER_TABLE
    , p9_a4 JTF_VARCHAR2_TABLE_300
    , p9_a5 JTF_NUMBER_TABLE
    , p9_a6 JTF_VARCHAR2_TABLE_100
    , p9_a7 JTF_NUMBER_TABLE
    , p9_a8 JTF_NUMBER_TABLE
    , p9_a9 JTF_VARCHAR2_TABLE_300
    , p9_a10 JTF_VARCHAR2_TABLE_100
    , p9_a11 JTF_VARCHAR2_TABLE_200
    , p9_a12 JTF_VARCHAR2_TABLE_200
    , p9_a13 JTF_VARCHAR2_TABLE_200
    , p9_a14 JTF_VARCHAR2_TABLE_200
    , p9_a15 JTF_VARCHAR2_TABLE_200
    , p9_a16 JTF_VARCHAR2_TABLE_200
    , p9_a17 JTF_VARCHAR2_TABLE_200
    , p9_a18 JTF_VARCHAR2_TABLE_200
    , p9_a19 JTF_VARCHAR2_TABLE_200
    , p9_a20 JTF_VARCHAR2_TABLE_200
    , p9_a21 JTF_VARCHAR2_TABLE_200
    , p9_a22 JTF_VARCHAR2_TABLE_200
    , p9_a23 JTF_VARCHAR2_TABLE_200
    , p9_a24 JTF_VARCHAR2_TABLE_200
    , p9_a25 JTF_VARCHAR2_TABLE_200
    , p9_a26 JTF_NUMBER_TABLE
    , p9_a27 JTF_NUMBER_TABLE
    , p9_a28 JTF_DATE_TABLE
    , p9_a29 JTF_NUMBER_TABLE
    , p9_a30 JTF_NUMBER_TABLE
    , p9_a31 JTF_NUMBER_TABLE
    , p9_a32 JTF_VARCHAR2_TABLE_100
    , p9_a33 JTF_NUMBER_TABLE
    , p10_a0 JTF_NUMBER_TABLE
    , p10_a1 JTF_NUMBER_TABLE
    , p10_a2 JTF_NUMBER_TABLE
    , p10_a3 JTF_NUMBER_TABLE
    , p10_a4 JTF_DATE_TABLE
    , p10_a5 JTF_NUMBER_TABLE
    , p10_a6 JTF_NUMBER_TABLE
    , p10_a7 JTF_VARCHAR2_TABLE_300
    , p10_a8 JTF_NUMBER_TABLE
    , p10_a9 JTF_NUMBER_TABLE
    , p10_a10 JTF_VARCHAR2_TABLE_300
    , p10_a11 JTF_VARCHAR2_TABLE_100
    , p10_a12 JTF_NUMBER_TABLE
    , p10_a13 JTF_NUMBER_TABLE
    , p10_a14 JTF_DATE_TABLE
    , p10_a15 JTF_DATE_TABLE
    , p10_a16 JTF_NUMBER_TABLE
    , p10_a17 JTF_NUMBER_TABLE
    , p10_a18 JTF_NUMBER_TABLE
    , p10_a19 JTF_NUMBER_TABLE
    , p10_a20 JTF_VARCHAR2_TABLE_100
    , p10_a21 JTF_VARCHAR2_TABLE_100
    , p10_a22 JTF_VARCHAR2_TABLE_100
    , p10_a23 JTF_VARCHAR2_TABLE_100
    , p10_a24 JTF_VARCHAR2_TABLE_100
    , p10_a25 JTF_NUMBER_TABLE
    , p10_a26 JTF_VARCHAR2_TABLE_100
    , p10_a27 JTF_DATE_TABLE
    , p10_a28 JTF_DATE_TABLE
    , p10_a29 JTF_VARCHAR2_TABLE_100
    , p10_a30 JTF_VARCHAR2_TABLE_200
    , p10_a31 JTF_VARCHAR2_TABLE_200
    , p10_a32 JTF_VARCHAR2_TABLE_200
    , p10_a33 JTF_VARCHAR2_TABLE_200
    , p10_a34 JTF_VARCHAR2_TABLE_200
    , p10_a35 JTF_VARCHAR2_TABLE_200
    , p10_a36 JTF_VARCHAR2_TABLE_200
    , p10_a37 JTF_VARCHAR2_TABLE_200
    , p10_a38 JTF_VARCHAR2_TABLE_200
    , p10_a39 JTF_VARCHAR2_TABLE_200
    , p10_a40 JTF_VARCHAR2_TABLE_200
    , p10_a41 JTF_VARCHAR2_TABLE_200
    , p10_a42 JTF_VARCHAR2_TABLE_200
    , p10_a43 JTF_VARCHAR2_TABLE_200
    , p10_a44 JTF_VARCHAR2_TABLE_200
    , p10_a45 JTF_NUMBER_TABLE
    , p10_a46 JTF_DATE_TABLE
    , p10_a47 JTF_NUMBER_TABLE
    , p10_a48 JTF_NUMBER_TABLE
    , p10_a49 JTF_VARCHAR2_TABLE_100
    , p10_a50 JTF_NUMBER_TABLE
    , p11_a0 JTF_NUMBER_TABLE
    , p11_a1 JTF_NUMBER_TABLE
    , p11_a2 JTF_NUMBER_TABLE
    , p11_a3 JTF_NUMBER_TABLE
    , p11_a4 JTF_NUMBER_TABLE
    , p11_a5 JTF_NUMBER_TABLE
    , p11_a6 JTF_NUMBER_TABLE
    , p11_a7 JTF_DATE_TABLE
    , p11_a8 JTF_DATE_TABLE
    , p11_a9 JTF_VARCHAR2_TABLE_100
    , p11_a10 JTF_NUMBER_TABLE
    , p11_a11 JTF_VARCHAR2_TABLE_100
    , p11_a12 JTF_VARCHAR2_TABLE_100
    , p11_a13 JTF_VARCHAR2_TABLE_200
    , p11_a14 JTF_VARCHAR2_TABLE_200
    , p11_a15 JTF_VARCHAR2_TABLE_200
    , p11_a16 JTF_VARCHAR2_TABLE_200
    , p11_a17 JTF_VARCHAR2_TABLE_200
    , p11_a18 JTF_VARCHAR2_TABLE_200
    , p11_a19 JTF_VARCHAR2_TABLE_200
    , p11_a20 JTF_VARCHAR2_TABLE_200
    , p11_a21 JTF_VARCHAR2_TABLE_200
    , p11_a22 JTF_VARCHAR2_TABLE_200
    , p11_a23 JTF_VARCHAR2_TABLE_200
    , p11_a24 JTF_VARCHAR2_TABLE_200
    , p11_a25 JTF_VARCHAR2_TABLE_200
    , p11_a26 JTF_VARCHAR2_TABLE_200
    , p11_a27 JTF_VARCHAR2_TABLE_200
    , p11_a28 JTF_VARCHAR2_TABLE_200
    , p11_a29 JTF_VARCHAR2_TABLE_200
    , p11_a30 JTF_VARCHAR2_TABLE_200
    , p11_a31 JTF_VARCHAR2_TABLE_200
    , p11_a32 JTF_VARCHAR2_TABLE_200
    , p11_a33 JTF_VARCHAR2_TABLE_200
    , p11_a34 JTF_VARCHAR2_TABLE_200
    , p11_a35 JTF_VARCHAR2_TABLE_200
    , p11_a36 JTF_VARCHAR2_TABLE_200
    , p11_a37 JTF_VARCHAR2_TABLE_200
    , p11_a38 JTF_VARCHAR2_TABLE_200
    , p11_a39 JTF_VARCHAR2_TABLE_200
    , p11_a40 JTF_VARCHAR2_TABLE_200
    , p11_a41 JTF_VARCHAR2_TABLE_200
    , p11_a42 JTF_VARCHAR2_TABLE_200
    , p11_a43 JTF_NUMBER_TABLE
    , p11_a44 JTF_VARCHAR2_TABLE_100
    , p11_a45 JTF_VARCHAR2_TABLE_100
    , p11_a46 JTF_VARCHAR2_TABLE_100
    , p11_a47 JTF_NUMBER_TABLE
    , p12_a0 JTF_NUMBER_TABLE
    , p12_a1 JTF_NUMBER_TABLE
    , p12_a2 JTF_NUMBER_TABLE
    , p12_a3 JTF_NUMBER_TABLE
    , p12_a4 JTF_NUMBER_TABLE
    , p12_a5 JTF_NUMBER_TABLE
    , p12_a6 JTF_VARCHAR2_TABLE_300
    , p12_a7 JTF_DATE_TABLE
    , p12_a8 JTF_VARCHAR2_TABLE_100
    , p12_a9 JTF_VARCHAR2_TABLE_100
    , p12_a10 JTF_VARCHAR2_TABLE_200
    , p12_a11 JTF_VARCHAR2_TABLE_200
    , p12_a12 JTF_VARCHAR2_TABLE_200
    , p12_a13 JTF_VARCHAR2_TABLE_200
    , p12_a14 JTF_VARCHAR2_TABLE_200
    , p12_a15 JTF_VARCHAR2_TABLE_200
    , p12_a16 JTF_VARCHAR2_TABLE_200
    , p12_a17 JTF_VARCHAR2_TABLE_200
    , p12_a18 JTF_VARCHAR2_TABLE_200
    , p12_a19 JTF_VARCHAR2_TABLE_200
    , p12_a20 JTF_VARCHAR2_TABLE_200
    , p12_a21 JTF_VARCHAR2_TABLE_200
    , p12_a22 JTF_VARCHAR2_TABLE_200
    , p12_a23 JTF_VARCHAR2_TABLE_200
    , p12_a24 JTF_VARCHAR2_TABLE_200
    , p12_a25 JTF_VARCHAR2_TABLE_100
    , p12_a26 JTF_NUMBER_TABLE
    , p13_a0 JTF_NUMBER_TABLE
    , p13_a1 JTF_NUMBER_TABLE
    , p13_a2 JTF_NUMBER_TABLE
    , p13_a3 JTF_NUMBER_TABLE
    , p13_a4 JTF_NUMBER_TABLE
    , p13_a5 JTF_NUMBER_TABLE
    , p13_a6 JTF_NUMBER_TABLE
    , p13_a7 JTF_NUMBER_TABLE
    , p13_a8 JTF_VARCHAR2_TABLE_100
    , p13_a9 JTF_NUMBER_TABLE
    , p13_a10 JTF_VARCHAR2_TABLE_100
    , p13_a11 JTF_NUMBER_TABLE
    , p14_a0 JTF_NUMBER_TABLE
    , p14_a1 JTF_NUMBER_TABLE
    , p14_a2 JTF_NUMBER_TABLE
    , p14_a3 JTF_NUMBER_TABLE
    , p14_a4 JTF_NUMBER_TABLE
    , p14_a5 JTF_VARCHAR2_TABLE_100
    , p14_a6 JTF_NUMBER_TABLE
    , p14_a7 JTF_NUMBER_TABLE
    , p14_a8 JTF_VARCHAR2_TABLE_100
    , p14_a9 JTF_NUMBER_TABLE
    , p15_a0 JTF_NUMBER_TABLE
    , p15_a1 JTF_NUMBER_TABLE
    , p15_a2 JTF_NUMBER_TABLE
    , p15_a3 JTF_NUMBER_TABLE
    , p15_a4 JTF_NUMBER_TABLE
    , p15_a5 JTF_VARCHAR2_TABLE_300
    , p15_a6 JTF_NUMBER_TABLE
    , p15_a7 JTF_VARCHAR2_TABLE_300
    , p15_a8 JTF_NUMBER_TABLE
    , p15_a9 JTF_NUMBER_TABLE
    , p15_a10 JTF_DATE_TABLE
    , p15_a11 JTF_DATE_TABLE
    , p15_a12 JTF_VARCHAR2_TABLE_100
    , p15_a13 JTF_DATE_TABLE
    , p15_a14 JTF_NUMBER_TABLE
    , p15_a15 JTF_VARCHAR2_TABLE_100
    , p15_a16 JTF_VARCHAR2_TABLE_300
    , p15_a17 JTF_VARCHAR2_TABLE_300
    , p15_a18 JTF_VARCHAR2_TABLE_300
    , p15_a19 JTF_VARCHAR2_TABLE_300
    , p15_a20 JTF_VARCHAR2_TABLE_300
    , p15_a21 JTF_VARCHAR2_TABLE_300
    , p15_a22 JTF_VARCHAR2_TABLE_300
    , p15_a23 JTF_VARCHAR2_TABLE_300
    , p15_a24 JTF_VARCHAR2_TABLE_300
    , p15_a25 JTF_VARCHAR2_TABLE_300
    , p15_a26 JTF_VARCHAR2_TABLE_300
    , p15_a27 JTF_VARCHAR2_TABLE_300
    , p15_a28 JTF_VARCHAR2_TABLE_300
    , p15_a29 JTF_VARCHAR2_TABLE_300
    , p15_a30 JTF_VARCHAR2_TABLE_300
    , p15_a31 JTF_VARCHAR2_TABLE_300
    , p15_a32 JTF_VARCHAR2_TABLE_300
    , p15_a33 JTF_VARCHAR2_TABLE_300
    , p15_a34 JTF_VARCHAR2_TABLE_300
    , p15_a35 JTF_VARCHAR2_TABLE_300
    , p15_a36 JTF_VARCHAR2_TABLE_300
    , p15_a37 JTF_VARCHAR2_TABLE_300
    , p15_a38 JTF_VARCHAR2_TABLE_300
    , p15_a39 JTF_VARCHAR2_TABLE_300
    , p15_a40 JTF_VARCHAR2_TABLE_300
    , p15_a41 JTF_VARCHAR2_TABLE_300
    , p15_a42 JTF_VARCHAR2_TABLE_300
    , p15_a43 JTF_VARCHAR2_TABLE_300
    , p15_a44 JTF_VARCHAR2_TABLE_300
    , p15_a45 JTF_VARCHAR2_TABLE_300
    , p15_a46 JTF_NUMBER_TABLE
    , p15_a47 JTF_NUMBER_TABLE
    , p15_a48 JTF_DATE_TABLE
    , p15_a49 JTF_NUMBER_TABLE
    , p15_a50 JTF_NUMBER_TABLE
    , p16_a0 JTF_NUMBER_TABLE
    , p16_a1 JTF_NUMBER_TABLE
    , p16_a2 JTF_NUMBER_TABLE
    , p16_a3 JTF_NUMBER_TABLE
    , p16_a4 JTF_NUMBER_TABLE
    , p16_a5 JTF_NUMBER_TABLE
    , p16_a6 JTF_NUMBER_TABLE
    , p16_a7 JTF_NUMBER_TABLE
    , p16_a8 JTF_VARCHAR2_TABLE_100
    , p16_a9 JTF_VARCHAR2_TABLE_300
    , p16_a10 JTF_VARCHAR2_TABLE_300
    , p16_a11 JTF_VARCHAR2_TABLE_300
    , p16_a12 JTF_VARCHAR2_TABLE_300
    , p16_a13 JTF_VARCHAR2_TABLE_300
    , p16_a14 JTF_VARCHAR2_TABLE_300
    , p16_a15 JTF_VARCHAR2_TABLE_300
    , p16_a16 JTF_VARCHAR2_TABLE_300
    , p16_a17 JTF_VARCHAR2_TABLE_300
    , p16_a18 JTF_VARCHAR2_TABLE_300
    , p16_a19 JTF_VARCHAR2_TABLE_300
    , p16_a20 JTF_VARCHAR2_TABLE_300
    , p16_a21 JTF_VARCHAR2_TABLE_300
    , p16_a22 JTF_VARCHAR2_TABLE_300
    , p16_a23 JTF_VARCHAR2_TABLE_300
    , p16_a24 JTF_VARCHAR2_TABLE_300
    , p16_a25 JTF_VARCHAR2_TABLE_300
    , p16_a26 JTF_VARCHAR2_TABLE_300
    , p16_a27 JTF_VARCHAR2_TABLE_300
    , p16_a28 JTF_VARCHAR2_TABLE_300
    , p16_a29 JTF_VARCHAR2_TABLE_300
    , p16_a30 JTF_VARCHAR2_TABLE_300
    , p16_a31 JTF_VARCHAR2_TABLE_300
    , p16_a32 JTF_VARCHAR2_TABLE_300
    , p16_a33 JTF_VARCHAR2_TABLE_300
    , p16_a34 JTF_VARCHAR2_TABLE_300
    , p16_a35 JTF_VARCHAR2_TABLE_300
    , p16_a36 JTF_VARCHAR2_TABLE_300
    , p16_a37 JTF_VARCHAR2_TABLE_300
    , p16_a38 JTF_VARCHAR2_TABLE_300
    , p16_a39 JTF_NUMBER_TABLE
    , p16_a40 JTF_DATE_TABLE
    , p_prev_activity_id  NUMBER
    , p_failure_id  NUMBER
    , p_failure_date  DATE
    , p_failure_entry_id  NUMBER
    , p_failure_code  VARCHAR2
    , p_cause_code  VARCHAR2
    , p_resolution_code  VARCHAR2
    , p_failure_comments  VARCHAR2
    , p_failure_code_required  VARCHAR2
    , x_wip_entity_id out nocopy  NUMBER
    , x_return_status out nocopy  VARCHAR2
    , x_msg_count out nocopy  NUMBER
  )

  as
    ddp_eam_wo_tbl eam_process_wo_pub.eam_wo_tbl_type;
    ddp_eam_wo_relations_tbl eam_process_wo_pub.eam_wo_relations_tbl_type;
    ddp_eam_op_tbl eam_process_wo_pub.eam_op_tbl_type;
    ddp_eam_res_tbl eam_process_wo_pub.eam_res_tbl_type;
    ddp_eam_res_inst_tbl eam_process_wo_pub.eam_res_inst_tbl_type;
    ddp_eam_res_usage_tbl eam_process_wo_pub.eam_res_usage_tbl_type;
    ddp_eam_mat_req_tbl eam_process_wo_pub.eam_mat_req_tbl_type;
    ddp_eam_direct_items_tbl eam_process_wo_pub.eam_direct_items_tbl_type;
    ddp_eam_request_tbl eam_process_wo_pub.eam_request_tbl_type;
    ddp_eam_wo_comp_tbl eam_process_wo_pub.eam_wo_comp_tbl_type;
    ddp_eam_meter_reading_tbl eam_process_wo_pub.eam_meter_reading_tbl_type;
    ddp_eam_counter_prop_tbl eam_process_wo_pub.eam_counter_prop_tbl_type;
    ddp_eam_wo_comp_rebuild_tbl eam_process_wo_pub.eam_wo_comp_rebuild_tbl_type;
    ddp_eam_wo_comp_mr_read_tbl eam_process_wo_pub.eam_wo_comp_mr_read_tbl_type;
    ddp_eam_permit_tbl eam_process_permit_pub.eam_wp_tbl_type;
    ddp_eam_permit_wo_assoc_tbl eam_process_permit_pub.eam_wp_association_tbl_type;
    ddindx binary_integer; indx binary_integer;
  begin

    -- copy data to the local IN or IN-OUT args, if any

    eam_process_wo_pub_w.rosetta_table_copy_in_p27(ddp_eam_wo_tbl, p1_a0
      , p1_a1
      , p1_a2
      , p1_a3
      , p1_a4
      , p1_a5
      , p1_a6
      , p1_a7
      , p1_a8
      , p1_a9
      , p1_a10
      , p1_a11
      , p1_a12
      , p1_a13
      , p1_a14
      , p1_a15
      , p1_a16
      , p1_a17
      , p1_a18
      , p1_a19
      , p1_a20
      , p1_a21
      , p1_a22
      , p1_a23
      , p1_a24
      , p1_a25
      , p1_a26
      , p1_a27
      , p1_a28
      , p1_a29
      , p1_a30
      , p1_a31
      , p1_a32
      , p1_a33
      , p1_a34
      , p1_a35
      , p1_a36
      , p1_a37
      , p1_a38
      , p1_a39
      , p1_a40
      , p1_a41
      , p1_a42
      , p1_a43
      , p1_a44
      , p1_a45
      , p1_a46
      , p1_a47
      , p1_a48
      , p1_a49
      , p1_a50
      , p1_a51
      , p1_a52
      , p1_a53
      , p1_a54
      , p1_a55
      , p1_a56
      , p1_a57
      , p1_a58
      , p1_a59
      , p1_a60
      , p1_a61
      , p1_a62
      , p1_a63
      , p1_a64
      , p1_a65
      , p1_a66
      , p1_a67
      , p1_a68
      , p1_a69
      , p1_a70
      , p1_a71
      , p1_a72
      , p1_a73
      , p1_a74
      , p1_a75
      , p1_a76
      , p1_a77
      , p1_a78
      , p1_a79
      , p1_a80
      , p1_a81
      , p1_a82
      , p1_a83
      , p1_a84
      , p1_a85
      , p1_a86
      , p1_a87
      , p1_a88
      , p1_a89
      , p1_a90
      , p1_a91
      , p1_a92
      , p1_a93
      , p1_a94
      , p1_a95
      , p1_a96
      , p1_a97
      , p1_a98
      , p1_a99
      , p1_a100
      , p1_a101
      , p1_a102
      , p1_a103
      , p1_a104
      , p1_a105
      , p1_a106
      , p1_a107
      , p1_a108
      , p1_a109
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p25(ddp_eam_wo_relations_tbl, p2_a0
      , p2_a1
      , p2_a2
      , p2_a3
      , p2_a4
      , p2_a5
      , p2_a6
      , p2_a7
      , p2_a8
      , p2_a9
      , p2_a10
      , p2_a11
      , p2_a12
      , p2_a13
      , p2_a14
      , p2_a15
      , p2_a16
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p28(ddp_eam_op_tbl, p3_a0
      , p3_a1
      , p3_a2
      , p3_a3
      , p3_a4
      , p3_a5
      , p3_a6
      , p3_a7
      , p3_a8
      , p3_a9
      , p3_a10
      , p3_a11
      , p3_a12
      , p3_a13
      , p3_a14
      , p3_a15
      , p3_a16
      , p3_a17
      , p3_a18
      , p3_a19
      , p3_a20
      , p3_a21
      , p3_a22
      , p3_a23
      , p3_a24
      , p3_a25
      , p3_a26
      , p3_a27
      , p3_a28
      , p3_a29
      , p3_a30
      , p3_a31
      , p3_a32
      , p3_a33
      , p3_a34
      , p3_a35
      , p3_a36
      , p3_a37
      , p3_a38
      , p3_a39
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p30(ddp_eam_res_tbl, p4_a0
      , p4_a1
      , p4_a2
      , p4_a3
      , p4_a4
      , p4_a5
      , p4_a6
      , p4_a7
      , p4_a8
      , p4_a9
      , p4_a10
      , p4_a11
      , p4_a12
      , p4_a13
      , p4_a14
      , p4_a15
      , p4_a16
      , p4_a17
      , p4_a18
      , p4_a19
      , p4_a20
      , p4_a21
      , p4_a22
      , p4_a23
      , p4_a24
      , p4_a25
      , p4_a26
      , p4_a27
      , p4_a28
      , p4_a29
      , p4_a30
      , p4_a31
      , p4_a32
      , p4_a33
      , p4_a34
      , p4_a35
      , p4_a36
      , p4_a37
      , p4_a38
      , p4_a39
      , p4_a40
      , p4_a41
      , p4_a42
      , p4_a43
      , p4_a44
      , p4_a45
      , p4_a46
      , p4_a47
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p31(ddp_eam_res_inst_tbl, p5_a0
      , p5_a1
      , p5_a2
      , p5_a3
      , p5_a4
      , p5_a5
      , p5_a6
      , p5_a7
      , p5_a8
      , p5_a9
      , p5_a10
      , p5_a11
      , p5_a12
      , p5_a13
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p33(ddp_eam_res_usage_tbl, p6_a0
      , p6_a1
      , p6_a2
      , p6_a3
      , p6_a4
      , p6_a5
      , p6_a6
      , p6_a7
      , p6_a8
      , p6_a9
      , p6_a10
      , p6_a11
      , p6_a12
      , p6_a13
      , p6_a14
      , p6_a15
      , p6_a16
      , p6_a17
      , p6_a18
      , p6_a19
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p34(ddp_eam_mat_req_tbl, p7_a0
      , p7_a1
      , p7_a2
      , p7_a3
      , p7_a4
      , p7_a5
      , p7_a6
      , p7_a7
      , p7_a8
      , p7_a9
      , p7_a10
      , p7_a11
      , p7_a12
      , p7_a13
      , p7_a14
      , p7_a15
      , p7_a16
      , p7_a17
      , p7_a18
      , p7_a19
      , p7_a20
      , p7_a21
      , p7_a22
      , p7_a23
      , p7_a24
      , p7_a25
      , p7_a26
      , p7_a27
      , p7_a28
      , p7_a29
      , p7_a30
      , p7_a31
      , p7_a32
      , p7_a33
      , p7_a34
      , p7_a35
      , p7_a36
      , p7_a37
      , p7_a38
      , p7_a39
      , p7_a40
      , p7_a41
      , p7_a42
      , p7_a43
      , p7_a44
      , p7_a45
      , p7_a46
      , p7_a47
      , p7_a48
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p35(ddp_eam_direct_items_tbl, p8_a0
      , p8_a1
      , p8_a2
      , p8_a3
      , p8_a4
      , p8_a5
      , p8_a6
      , p8_a7
      , p8_a8
      , p8_a9
      , p8_a10
      , p8_a11
      , p8_a12
      , p8_a13
      , p8_a14
      , p8_a15
      , p8_a16
      , p8_a17
      , p8_a18
      , p8_a19
      , p8_a20
      , p8_a21
      , p8_a22
      , p8_a23
      , p8_a24
      , p8_a25
      , p8_a26
      , p8_a27
      , p8_a28
      , p8_a29
      , p8_a30
      , p8_a31
      , p8_a32
      , p8_a33
      , p8_a34
      , p8_a35
      , p8_a36
      , p8_a37
      , p8_a38
      , p8_a39
      , p8_a40
      , p8_a41
      , p8_a42
      , p8_a43
      , p8_a44
      , p8_a45
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p43(ddp_eam_request_tbl, p9_a0
      , p9_a1
      , p9_a2
      , p9_a3
      , p9_a4
      , p9_a5
      , p9_a6
      , p9_a7
      , p9_a8
      , p9_a9
      , p9_a10
      , p9_a11
      , p9_a12
      , p9_a13
      , p9_a14
      , p9_a15
      , p9_a16
      , p9_a17
      , p9_a18
      , p9_a19
      , p9_a20
      , p9_a21
      , p9_a22
      , p9_a23
      , p9_a24
      , p9_a25
      , p9_a26
      , p9_a27
      , p9_a28
      , p9_a29
      , p9_a30
      , p9_a31
      , p9_a32
      , p9_a33
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p36(ddp_eam_wo_comp_tbl, p10_a0
      , p10_a1
      , p10_a2
      , p10_a3
      , p10_a4
      , p10_a5
      , p10_a6
      , p10_a7
      , p10_a8
      , p10_a9
      , p10_a10
      , p10_a11
      , p10_a12
      , p10_a13
      , p10_a14
      , p10_a15
      , p10_a16
      , p10_a17
      , p10_a18
      , p10_a19
      , p10_a20
      , p10_a21
      , p10_a22
      , p10_a23
      , p10_a24
      , p10_a25
      , p10_a26
      , p10_a27
      , p10_a28
      , p10_a29
      , p10_a30
      , p10_a31
      , p10_a32
      , p10_a33
      , p10_a34
      , p10_a35
      , p10_a36
      , p10_a37
      , p10_a38
      , p10_a39
      , p10_a40
      , p10_a41
      , p10_a42
      , p10_a43
      , p10_a44
      , p10_a45
      , p10_a46
      , p10_a47
      , p10_a48
      , p10_a49
      , p10_a50
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p38(ddp_eam_meter_reading_tbl, p11_a0
      , p11_a1
      , p11_a2
      , p11_a3
      , p11_a4
      , p11_a5
      , p11_a6
      , p11_a7
      , p11_a8
      , p11_a9
      , p11_a10
      , p11_a11
      , p11_a12
      , p11_a13
      , p11_a14
      , p11_a15
      , p11_a16
      , p11_a17
      , p11_a18
      , p11_a19
      , p11_a20
      , p11_a21
      , p11_a22
      , p11_a23
      , p11_a24
      , p11_a25
      , p11_a26
      , p11_a27
      , p11_a28
      , p11_a29
      , p11_a30
      , p11_a31
      , p11_a32
      , p11_a33
      , p11_a34
      , p11_a35
      , p11_a36
      , p11_a37
      , p11_a38
      , p11_a39
      , p11_a40
      , p11_a41
      , p11_a42
      , p11_a43
      , p11_a44
      , p11_a45
      , p11_a46
      , p11_a47
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p39(ddp_eam_counter_prop_tbl, p12_a0
      , p12_a1
      , p12_a2
      , p12_a3
      , p12_a4
      , p12_a5
      , p12_a6
      , p12_a7
      , p12_a8
      , p12_a9
      , p12_a10
      , p12_a11
      , p12_a12
      , p12_a13
      , p12_a14
      , p12_a15
      , p12_a16
      , p12_a17
      , p12_a18
      , p12_a19
      , p12_a20
      , p12_a21
      , p12_a22
      , p12_a23
      , p12_a24
      , p12_a25
      , p12_a26
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p41(ddp_eam_wo_comp_rebuild_tbl, p13_a0
      , p13_a1
      , p13_a2
      , p13_a3
      , p13_a4
      , p13_a5
      , p13_a6
      , p13_a7
      , p13_a8
      , p13_a9
      , p13_a10
      , p13_a11
      );

    eam_process_wo_pub_w.rosetta_table_copy_in_p42(ddp_eam_wo_comp_mr_read_tbl, p14_a0
      , p14_a1
      , p14_a2
      , p14_a3
      , p14_a4
      , p14_a5
      , p14_a6
      , p14_a7
      , p14_a8
      , p14_a9
      );

    eam_process_permit_pub_w.rosetta_table_copy_in_p2(ddp_eam_permit_tbl, p15_a0
      , p15_a1
      , p15_a2
      , p15_a3
      , p15_a4
      , p15_a5
      , p15_a6
      , p15_a7
      , p15_a8
      , p15_a9
      , p15_a10
      , p15_a11
      , p15_a12
      , p15_a13
      , p15_a14
      , p15_a15
      , p15_a16
      , p15_a17
      , p15_a18
      , p15_a19
      , p15_a20
      , p15_a21
      , p15_a22
      , p15_a23
      , p15_a24
      , p15_a25
      , p15_a26
      , p15_a27
      , p15_a28
      , p15_a29
      , p15_a30
      , p15_a31
      , p15_a32
      , p15_a33
      , p15_a34
      , p15_a35
      , p15_a36
      , p15_a37
      , p15_a38
      , p15_a39
      , p15_a40
      , p15_a41
      , p15_a42
      , p15_a43
      , p15_a44
      , p15_a45
      , p15_a46
      , p15_a47
      , p15_a48
      , p15_a49
      , p15_a50
      );

    eam_process_permit_pub_w.rosetta_table_copy_in_p3(ddp_eam_permit_wo_assoc_tbl, p16_a0
      , p16_a1
      , p16_a2
      , p16_a3
      , p16_a4
      , p16_a5
      , p16_a6
      , p16_a7
      , p16_a8
      , p16_a9
      , p16_a10
      , p16_a11
      , p16_a12
      , p16_a13
      , p16_a14
      , p16_a15
      , p16_a16
      , p16_a17
      , p16_a18
      , p16_a19
      , p16_a20
      , p16_a21
      , p16_a22
      , p16_a23
      , p16_a24
      , p16_a25
      , p16_a26
      , p16_a27
      , p16_a28
      , p16_a29
      , p16_a30
      , p16_a31
      , p16_a32
      , p16_a33
      , p16_a34
      , p16_a35
      , p16_a36
      , p16_a37
      , p16_a38
      , p16_a39
      , p16_a40
      );













    -- here's the delegated call to the old PL/SQL routine
    eam_createupdate_wo_pvt.create_update_wo(p_commit,
      ddp_eam_wo_tbl,
      ddp_eam_wo_relations_tbl,
      ddp_eam_op_tbl,
      ddp_eam_res_tbl,
      ddp_eam_res_inst_tbl,
      ddp_eam_res_usage_tbl,
      ddp_eam_mat_req_tbl,
      ddp_eam_direct_items_tbl,
      ddp_eam_request_tbl,
      ddp_eam_wo_comp_tbl,
      ddp_eam_meter_reading_tbl,
      ddp_eam_counter_prop_tbl,
      ddp_eam_wo_comp_rebuild_tbl,
      ddp_eam_wo_comp_mr_read_tbl,
      ddp_eam_permit_tbl,
      ddp_eam_permit_wo_assoc_tbl,
      p_prev_activity_id,
      p_failure_id,
      p_failure_date,
      p_failure_entry_id,
      p_failure_code,
      p_cause_code,
      p_resolution_code,
      p_failure_comments,
      p_failure_code_required,
      x_wip_entity_id,
      x_return_status,
      x_msg_count);

    -- copy data back from the local variables to OUT or IN-OUT args, if any




























  end;

end eam_createupdate_wo_pvt_w;

/
