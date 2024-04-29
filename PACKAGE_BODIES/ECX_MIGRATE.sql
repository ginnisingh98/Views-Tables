--------------------------------------------------------
--  DDL for Package Body ECX_MIGRATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ECX_MIGRATE" 
-- $Header: ECXPMIRB.plb 120.2 2005/11/04 11:55:35 sbastida ship $
wrapped
0
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
abcd
b
8003000
1
4
0
56
7 PACKAGE:
4 BODY:
b ECX_MIGRATE:
6 CURSOR:
b HUB_USERS_C:
b HUB_USER_ID:
8 PASSWORD:
d ECX_HUB_USERS:
b IS NOT NULL:
f HUB_USERS_C_REC:
7 ROWTYPE:
10 ECX_TP_DETAILS_C:
c TP_DETAIL_ID:
e ECX_TP_DETAILS:
12 ECX_TP_DETAILS_REC:
f P_DECRYPT_VALUE:
8 VARCHAR2:
3 240:
f P_ENCRYPT_VALUE:
8 P_ERRMSG:
9 P_RETCODE:
b PLS_INTEGER:
14 ECX_MIGRATE_PASSWORD:
6 ERRMSG:
3 OUT:
7 RETCODE:
d HUB_USERS_REC:
4 LOOP:
d ECX_OBFUSCATE:
10 ECX_DATA_ENCRYPT:
e L_INPUT_STRING:
b L_QUAL_CODE:
1 D:
f L_OUTPUT_STRING:
1 =:
1 0:
10 LAST_UPDATE_DATE:
7 SYSDATE:
6 OTHERS:
7 SQLERRM:
2 ||:
3b At ECX_MIGRATE.ECX_MIGRATE_PASSWORD for table ecx_hub_users:
9 ECX_UTILS:
a ERROR_TYPE:
2 30:
1 2:
3c At ECX_MIGRATE.ECX_MIGRATE_PASSWORD for table ecx_tp_details:
8 PMIGRATE:
c P_DEBUG_MODE:
7 L_OUT_1:
4 2000:
c L_OLD_STRING:
c L_NEW_STRING:
5 L_MSG:
9 L_RETCODE:
7 L_MSG_2:
b L_RETCODE_2:
f GETLOGDIRECTORY:
9 ECX_DEBUG:
10 ENABLE_DEBUG_NEW:
8 G_LOGDIR:
8 PMIG.log:
2 PL:
1 3:
d Tp Detail Id :
1 I:
1 1:
1 5:
4 EXIT:
2b Unable to migrate password for Tp Detail id:
c Tp Detail Id:
9 Sql Error:
8 RetcodeD:
7 RetmsgD:
8 RetcodeE:
7 RetmsgE:
8 ROWCOUNT:
25 Password not updated for tp_detail_id:
b Row updated:
c Hub User Id :
2a Unable to migrate password for Hub User Id:
b Hub User Id:
24 Password not updated for Hub User Id:
9 PRINT_LOG:
d DISABLE_DEBUG:
10 Unexpected ERROR:
0

0
0
38d
2
0 a0 1d a0 97 a0 f4 b4
bf c8 :2 a0 ac a0 b2 ee a0
7e b4 2e ac d0 e5 e9 bd
b7 11 a4 b1 a3 :2 a0 f 1c
81 b0 a0 f4 b4 bf c8 :2 a0
ac a0 b2 ee a0 7e b4 2e
ac d0 e5 e9 bd b7 11 a4
b1 a3 :2 a0 f 1c 81 b0 a3
a0 51 a5 1c 81 b0 a3 a0
51 a5 1c 81 b0 a3 a0 51
a5 1c 81 b0 a3 a0 1c 81
b0 9a 96 :2 a0 b0 54 96 :2 a0
b0 54 b4 55 6a 91 :2 a0 37
:2 a0 6b :3 a0 6b e a0 6e e
:2 a0 e :2 a0 e :2 a0 e a5 57
a0 7e 51 b4 2e :2 a0 6b :2 a0
e :2 a0 e :2 a0 e :2 a0 e a5
57 b7 :2 a0 6b :3 a0 6b e :2 a0
e :2 a0 e :2 a0 e a5 57 b7
:2 19 3c a0 7e 51 b4 2e :3 a0
e7 :2 a0 e7 :2 a0 7e a0 6b b4
2e ef f9 e9 b7 19 3c b7
a0 53 :2 a0 7e 6e b4 2e d
:2 a0 6b 51 d a0 51 d b7
a6 9 a4 b1 11 4f b7 a0
47 91 :2 a0 37 :2 a0 6b :3 a0 6b
e a0 6e e :2 a0 e :2 a0 e
:2 a0 e a5 57 a0 7e 51 b4
2e :2 a0 6b :2 a0 e :2 a0 e :2 a0
e :2 a0 e a5 57 b7 :2 a0 6b
:3 a0 6b e :2 a0 e :2 a0 e :2 a0
e a5 57 b7 :2 19 3c a0 7e
51 b4 2e :3 a0 e7 :2 a0 e7 :2 a0
7e a0 6b b4 2e ef f9 e9
b7 19 3c b7 a0 53 :2 a0 7e
6e b4 2e d :2 a0 6b 51 d
a0 51 d b7 a6 9 a4 b1
11 4f b7 a0 47 b7 a0 53
4f b7 a6 9 a4 b1 11 68
4f 9a 8f a0 b0 3d b4 a3
55 6a a0 51 a5 1c 81 b0
a3 a0 51 a5 1c 81 b0 a3
a0 51 a5 1c 81 b0 a3 a0
51 a5 1c 81 b0 a3 a0 1c
51 81 b0 a3 a0 51 a5 1c
81 b0 a3 a0 1c 51 81 b0
:2 a0 6b 57 b3 :2 a0 6b :3 a0 6b
:2 6e a5 57 91 :2 a0 37 :2 a0 6b
51 6e :2 a0 6b a5 57 91 :2 51
a0 63 37 :2 a0 6b :2 a0 6b 6e
:3 a0 a5 57 :2 a0 7e 51 b4 2e
2b b7 a0 47 a0 7e 51 b4
2e 5a :2 a0 6b :4 a0 a5 57 b7
:2 a0 6b 51 6e :2 a0 6b a5 57
a0 4d d b7 :2 19 3c b7 a0
53 :2 a0 6b 51 6e :2 a0 6b a5
57 :2 a0 6b 51 6e a0 a5 57
:2 a0 6b 51 6e a0 a5 57 :2 a0
6b 51 6e a0 a5 57 :2 a0 6b
51 6e a0 a5 57 :2 a0 6b 51
6e a0 a5 57 b7 a6 9 a4
b1 11 4f a0 7e b4 2e 5a
:3 a0 e7 :2 a0 e7 :2 a0 7e a0 6b
b4 2e ef f9 e9 a0 f 7e
51 b4 2e :2 a0 6b 51 6e :2 a0
6b a5 57 b7 :2 a0 6b 51 6e
:2 a0 6b a5 57 b7 :2 19 3c b7
19 3c a0 4d d a0 4d d
a0 4d d a0 4d d a0 51
d a0 51 d b7 a0 47 91
:2 a0 37 :2 a0 6b 51 6e :2 a0 6b
a5 57 91 :2 51 a0 63 37 :2 a0
6b :2 a0 6b 6e :3 a0 a5 57 :2 a0
7e 51 b4 2e 2b b7 a0 47
a0 7e 51 b4 2e 5a :2 a0 6b
:4 a0 a5 57 b7 :2 a0 6b 51 6e
:2 a0 6b a5 57 b7 :2 19 3c b7
a0 53 :2 a0 6b 51 6e :2 a0 6b
a5 57 :2 a0 6b 51 6e a0 a5
57 :2 a0 6b 51 6e a0 a5 57
:2 a0 6b 51 6e a0 a5 57 :2 a0
6b 51 6e a0 a5 57 :2 a0 6b
51 6e a0 a5 57 b7 a6 9
a4 b1 11 4f a0 7e b4 2e
5a :3 a0 e7 :2 a0 e7 :2 a0 7e a0
6b b4 2e ef f9 e9 a0 f
7e 51 b4 2e :2 a0 6b 51 6e
:2 a0 6b a5 57 b7 :2 a0 6b 51
6e :2 a0 6b a5 57 b7 :2 19 3c
b7 19 3c a0 4d d a0 4d
d a0 4d d a0 4d d a0
51 d a0 51 d b7 a0 47
:2 a0 6b b4 57 :2 a0 6b b4 57
b7 a0 53 :2 a0 6b 51 6e a0
a5 57 :2 a0 6b b4 57 :2 a0 6b
b4 57 b7 a6 9 a4 b1 11
68 4f b1 b7 a4 11 b1 56
4f 17 b5
38d
2
0 3 7 8 c 16 1a 29
2a 2d 31 35 39 3a 3e 3f
46 4a 4d 4e 53 54 58 5e
63 68 6a 75 79 97 7f 83
87 8b 93 7e 9e a2 7d b1
b4 b8 bc c0 c1 c5 c6 cd
d1 d4 d5 da db df e5 ea
7b ef fa fe 11c 104 108 10c
110 118 103 138 127 100 12b 12c
134 126 154 143 123 147 148 150
142 170 15f 13f 163 164 16c 15e
18b 17b 17f 187 15d 192 1aa 1a2
1a6 17a 1b0 1c1 1b9 1bd 179 1c7
1b8 1cc 1d0 1d4 1d8 1dc 177 1e0
1e4 1b5 1e8 1ec 1f0 1f4 15b 1f7
1fb 200 202 206 20a 20c 210 214
216 21a 21e 220 221 226 22a 22d
230 231 236 23a 23e 241 245 249
24b 24f 253 255 259 25d 25f 263
267 269 26a 26f 271 275 279 27c
280 284 288 28b 28d 291 295 297
29b 29f 2a1 2a5 2a9 2ab 2ac 2b1
2b3 2b7 2bb 2be 2c2 2c5 2c8 2c9
2ce 2d2 2d6 2da 2dc 2e0 2e4 2e6
2ea 2ee 2f1 2f5 2f8 2f9 2fe 304
305 30a 30c 310 313 315 1 319
31d 321 324 329 32a 32f 333 337
33b 33e 341 345 349 34c 350 352
353 358 35c 35e 369 36b 36d 371
378 37c 380 384 386 38a 38e 391
395 399 39d 3a0 3a2 3a6 3ab 3ad
3b1 3b5 3b7 3bb 3bf 3c1 3c5 3c9
3cb 3cc 3d1 3d5 3d8 3db 3dc 3e1
3e5 3e9 3ec 3f0 3f4 3f6 3fa 3fe
400 404 408 40a 40e 412 414 415
41a 41c 420 424 427 42b 42f 433
436 438 43c 440 442 446 44a 44c
450 454 456 457 45c 45e 462 466
469 46d 470 473 474 479 47d 481
485 487 48b 48f 491 495 499 49c
4a0 4a3 4a4 4a9 4af 4b0 4b5 4b7
4bb 4be 4c0 1 4c4 4c8 4cc 4cf
4d4 4d5 4da 4de 4e2 4e6 4e9 4ec
4f0 4f4 4f7 4fb 4fd 4fe 503 507
509 514 516 518 51c 523 525 1
529 52b 52d 52e 533 537 539 544
548 54a 562 55e 55d 56a 55c 58f
573 577 57b 57f 582 583 58b 572
5ab 59a 56f 59e 59f 5a7 599 5c7
5b6 596 5ba 5bb 5c3 5b5 5e3 5d2
5b2 5d6 5d7 5df 5d1 5fe 5ee 5f2
5ce 5fa 5ed 61a 609 5ea 60d 60e
616 608 635 625 629 605 631 624
63c 640 621 644 649 64a 64e 652
655 659 65d 661 664 669 66e 66f
674 678 67c 55a 680 684 688 68b
68e 693 697 69b 69e 69f 6a4 6a8
6ab 6ae 6b2 6b5 6b7 6bb 6bf 6c2
6c6 6ca 6cd 6d2 6d6 6da 6de 6df
6e4 6e8 6ec 6ef 6f2 6f3 6f8 6fe
700 704 70b 70f 712 715 716 71b
71e 722 726 729 72d 731 735 739
73a 73f 741 745 749 74c 74f 754
758 75c 75f 760 765 769 76a 76e
770 774 778 77b 77d 1 781 785
789 78c 78f 794 798 79c 79f 7a0
7a5 7a9 7ad 7b0 7b3 7b8 7bc 7bd
7c2 7c6 7ca 7cd 7d0 7d5 7d9 7da
7df 7e3 7e7 7ea 7ed 7f2 7f6 7f7
7fc 800 804 807 80a 80f 813 814
819 81d 821 824 827 82c 830 831
836 838 839 83e 842 844 84f 851
855 858 859 85e 861 865 869 86d
86f 873 877 879 87d 881 884 888
88b 88c 891 897 898 89d 8a1 8a5
8a8 8ab 8ac 8b1 8b5 8b9 8bc 8bf
8c4 8c8 8cc 8cf 8d0 8d5 8d7 8db
8df 8e2 8e5 8ea 8ee 8f2 8f5 8f6
8fb 8fd 901 905 908 90a 90e 911
915 916 91a 91e 91f 923 927 928
92c 930 931 935 939 93c 940 944
947 94b 94d 951 958 95c 960 964
966 96a 96e 971 974 979 97d 981
984 985 98a 98e 991 994 998 99b
99d 9a1 9a5 9a8 9ac 9b0 9b3 9b8
9bc 9c0 9c4 9c5 9ca 9ce 9d2 9d5
9d8 9d9 9de 9e4 9e6 9ea 9f1 9f5
9f8 9fb 9fc a01 a04 a08 a0c a0f
a13 a17 a1b a1f a20 a25 a27 a2b
a2f a32 a35 a3a a3e a42 a45 a46
a4b a4d a51 a55 a58 a5a 1 a5e
a62 a66 a69 a6c a71 a75 a79 a7c
a7d a82 a86 a8a a8d a90 a95 a99
a9a a9f aa3 aa7 aaa aad ab2 ab6
ab7 abc ac0 ac4 ac7 aca acf ad3
ad4 ad9 add ae1 ae4 ae7 aec af0
af1 af6 afa afe b01 b04 b09 b0d
b0e b13 b15 b16 b1b b1f b21 b2c
b2e b32 b35 b36 b3b b3e b42 b46
b4a b4c b50 b54 b56 b5a b5e b61
b65 b68 b69 b6e b74 b75 b7a b7e
b82 b85 b88 b89 b8e b92 b96 b99
b9c ba1 ba5 ba9 bac bad bb2 bb4
bb8 bbc bbf bc2 bc7 bcb bcf bd2
bd3 bd8 bda bde be2 be5 be7 beb
bee bf2 bf3 bf7 bfb bfc c00 c04
c05 c09 c0d c0e c12 c16 c19 c1d
c21 c24 c28 c2a c2e c35 c39 c3d
c40 c41 c46 c4a c4e c51 c52 c57
c59 1 c5d c61 c65 c68 c6b c70
c74 c75 c7a c7e c82 c85 c86 c8b
c8f c93 c96 c97 c9c c9e c9f ca4
ca8 caa cb5 cb9 cbb cbd cbf cc3
cce cd0 cd3 cd5 cdc
38d
2
0 :2 1 a f 3 a 0 :2 3
b 17 :2 b 4 :5 b :4 4 :5 3 4
15 21 :3 15 4 3 a 0 :2 3
b 18 :2 b 4 :5 b :4 4 :5 3 4
18 29 :3 18 :2 4 17 20 1f :2 17
:2 4 17 20 1f :2 17 :2 4 17 20
1f :2 17 :2 4 :3 17 4 b 20 27
2b :2 20 35 3d 41 :2 35 1f :2 1
7 18 4 3 9 :2 17 19 2c
:2 3a :2 19 2c :2 19 2c :2 19 2c :2 19
2c 19 :2 9 d 17 19 :2 17 d
:2 1b 19 2d :2 19 2d :2 19 2d :2 19
2d 19 :2 d 1b d :2 1b 19 2e
:2 3c :2 19 2e :2 19 2e :2 19 2e 19
:2 d :4 a b 15 17 :2 15 12 f
1a :2 f 21 f 11 1f 1d :2 2d
:2 1d :3 b 19 :2 8 6 :2 b 9 14
1c 1e :2 14 :2 9 :2 13 21 :2 9 13
9 12 :3 6 :4 4 7 3 7 1d
4 3 a :2 18 19 2b :2 3e :2 19
2b :2 19 2b :2 19 2b :2 19 2b 19
:2 a d 17 19 :2 17 d :2 1b 19
2d :2 19 2d :2 19 2d :2 19 2d 19
:2 d 1b d :2 1b 19 2e :2 41 :2 19
2e :2 19 2e :2 19 2e 19 :2 d :4 a
c 16 18 :2 16 13 10 1b :2 10
22 10 12 21 1f :2 34 :2 1f :3 c
1a :2 9 6 :2 e 9 14 1c 1e
:2 14 :2 9 :2 13 21 :2 9 13 9 15
:2 9 6 :4 4 9 3 1 :2 8 2
f :2 3 :5 1 b 14 21 :2 14 13
:3 1 f 18 17 :2 f :2 1 f 18
17 :2 f :2 1 f 18 17 :2 f :2 1
f 18 17 :2 f :2 1 :2 f 1e f
:2 1 f 18 17 :2 f :2 1 :2 f 1e
f :2 1 :2 b :3 1 :2 b 1c 29 :2 33
3c 48 :2 1 5 1b :2 1 6 :2 10
13 15 26 :2 39 :2 6 a f 12
6 f 6 8 :2 16 27 :2 3a :4 25
:3 8 12 1c 1e :2 1c 8 6 a
6 a 14 16 :2 14 9 8 :2 16
27 :3 25 :2 8 19 8 :2 12 15 18
15 :2 28 :3 8 18 8 :4 6 4 :2 8
5 :2 f 12 14 24 :2 37 :3 5 :2 f
12 14 21 :3 5 :2 f 12 14 1f
:3 5 :2 f 12 14 1f :3 5 :2 f 12
14 1f :3 5 :2 f 12 14 1f :2 5
f :3 3 :3 1 :4 7 6 :2 c 17 :2 c
1f :2 c 1b 19 :2 2e :2 19 :3 5 c
8 15 17 :2 15 7 :2 11 14 17
40 :2 53 :2 7 19 7 :2 11 14 16
25 :2 38 :2 7 :4 5 21 :3 3 13 :2 3
13 :2 3 c :2 3 e :2 3 10 :2 3
12 3 1 5 1 5 18 :2 1
6 :2 10 13 15 25 :2 35 :2 6 a
f 12 6 f 6 8 :2 16 27
:2 37 :4 25 :3 8 12 1c 1e :2 1c 8
6 a 6 a 14 16 :2 14 9
8 :2 16 27 :3 25 :2 8 19 8 :2 12
15 18 15 :2 25 :2 8 :4 6 3 :2 8
5 :2 f 12 14 23 :2 33 :3 5 :2 f
12 14 21 :3 5 :2 f 12 14 1f
:3 5 :2 f 12 14 1f :3 5 :2 f 12
14 1f :3 5 :2 f 12 14 1f :2 5
f :3 3 :3 1 :4 7 6 :2 c 17 :2 c
1f :2 c 1a 18 :2 2a :2 18 :3 5 c
8 15 17 :2 15 7 :2 11 14 17
3f :2 4f :2 7 19 7 :2 11 14 16
25 :2 35 :2 7 :4 5 21 :3 3 13 :2 3
13 :2 3 c :2 3 e :2 3 10 :2 3
12 3 1 5 :2 1 :2 b :3 1 :2 b
:3 1 :2 8 5 :2 f 12 14 27 :3 5
:2 f :3 5 :2 f :2 5 f :2 3 :e 1
38d
2
0 :4 1 :2 4 0 :2 4 :3 6 :3 7 :4 8
7 :3 6 :5 4 :7 a :2 c 0 :2 c :3 e
:3 f :4 10 f :3 e :5 c :7 12 :7 14 :7 15
:7 16 :5 17 :e 19 :2 1c 1d 1c :3 1f :5 20
:3 21 :3 22 :3 23 :3 24 :2 1f :5 26 :3 27 :3 28
:3 29 :3 2a :3 2b :2 27 26 :3 2d :5 2e :3 2f
:3 30 :3 31 :2 2d :2 2c :2 26 :5 34 35 :3 36
:3 38 :7 39 :3 35 :3 34 1e :2 3c :7 3d :5 3e
:3 3f :3 3c 3b :4 1d 41 1c :2 44 45
44 :3 47 :5 48 :3 49 :3 4a :3 4b :3 4c :2 47
:5 4e :3 4f :3 50 :3 51 :3 52 :3 53 :2 4f 4e
:3 55 :5 56 :3 57 :3 58 :3 59 :2 55 :2 54 :2 4e
:5 5b 5c :3 5d :3 5f :7 60 :3 5c :3 5b 46
:2 63 :7 64 :5 65 :3 66 :3 63 62 :4 45 68
44 1a :2 6a 6b :3 6a 69 :4 19 :6 73
75 :2 73 :6 75 :7 76 :7 77 :7 78 :6 79 :7 7a
:6 7b :5 7e :b 7f :2 81 82 81 :a 85 :3 86
87 :2 86 :6 88 89 8a 8b 8c :2 88
:7 8e 87 8f 86 :6 90 :4 91 92 93
94 :2 91 90 :5 97 :3 98 :2 97 :3 99 :2 96
:2 90 83 :2 9d :a 9e :8 9f :8 a0 :8 a1 :8 a2
:8 a3 :3 9d 9c :3 82 :5 a6 a7 :3 a8 :3 a9
:7 aa :3 a7 :6 ac :a ad ac :a af :2 ae :2 ac
:3 a6 :3 b2 :3 b3 :3 b4 :3 b5 :3 b6 :3 b7 82
b8 81 :2 ba bb ba :a be :3 bf c0
:2 bf :6 c1 c2 c3 c4 c5 :2 c1 :7 c7
c0 c8 bf :6 c9 :4 ca cb cc cd
:2 ca c9 :5 d0 :3 d1 :2 d0 :2 cf :2 c9 bc
:2 d5 :a d6 :8 d7 :8 d8 :8 d9 :8 da :8 db :3 d5
d4 :3 bb :5 de df :3 e0 :3 e1 :7 e2 :3 df
:6 e4 :a e5 e4 :a e7 :2 e6 :2 e4 :3 de :3 ea
:3 eb :3 ec :3 ed :3 ee :3 ef bb f0 ba
:5 f2 :5 f3 7d :2 f5 :8 f6 :5 f7 :5 f8 :3 f5
f4 :4 73 :4 19 :5 1
cde
2
:3 0 1 :4 0 2 :3 0 3 :6 0 1
:2 0 4 :3 0 5 :a 0 2 :4 0 6
9 0 7 :3 0 6 :3 0 7 :3 0
3 8 :3 0 6 e 13 0 14
:3 0 7 :3 0 9 :2 0 8 11 12
:5 0 c f 0 15 :6 0 16 :2 0
19 6 9 1a 0 388 a 1a
1c 19 1b :6 0 18 :6 0 1a 15
39 0 c 5 :3 0 b :3 0 1e
1f :2 0 20 :7 0 23 21 0 388
a :6 0 4 :3 0 c :a 0 3 :3 0
25 28 0 26 :3 0 d :3 0 7
:3 0 :2 e :3 0 11 2d 32 0 33
:3 0 7 :3 0 9 :2 0 13 30 31
:5 0 2b 2e 0 34 :6 0 35 :2 0
38 25 28 39 0 388 3b 38
3a :6 0 37 :6 0 39 12 :2 0 17
c :3 0 b :3 0 3d 3e :2 0 3f
:7 0 42 40 0 388 f :6 0 12
:2 0 1b 11 :3 0 19 44 46 :6 0
49 47 0 388 10 :6 0 12 :2 0
1f 11 :3 0 1d 4b 4d :6 0 50
4e 0 388 13 :6 0 72 75 25
23 11 :3 0 21 52 54 :6 0 57
55 0 388 14 :6 0 6b 6c 29
27 16 :3 0 59 :7 0 5c 5a 0
388 15 :6 0 17 :a 0 16f 4 :3 0
19 :3 0 11 :3 0 18 :5 0 61 60
:3 0 6f 70 0 2b 19 :3 0 16
:3 0 1a :5 0 66 65 :3 0 68 :2 0
16f 5d 69 :2 0 1b :3 0 5 :3 0
1c :3 0 1d :3 0 1e :3 0 1f :3 0
1b :3 0 7 :3 0 73 74 0 20
:3 0 21 :4 0 77 78 22 :3 0 10
:3 0 7a 7b 18 :3 0 14 :3 0 7d
7e 1a :3 0 15 :3 0 80 81 2e
71 83 :2 0 cc 15 :3 0 23 :2 0
24 :2 0 36 86 88 :3 0 1d :3 0
1e :3 0 8a 8b 0 1f :3 0 10
:3 0 8d 8e 22 :3 0 13 :3 0 90
91 18 :3 0 14 :3 0 93 94 1a
:3 0 15 :3 0 96 97 39 8c 99
:2 0 9b 34 b1 1d :3 0 1e :3 0
9c 9d 0 1f :3 0 1b :3 0 7
:3 0 a0 a1 0 9f a2 22 :3 0
13 :3 0 a4 a5 18 :3 0 14 :3 0
a7 a8 1a :3 0 15 :3 0 aa ab
3e 9e ad :2 0 af 43 b0 0
af 0 b2 89 9b 0 b2 45
0 cc 15 :3 0 23 :2 0 24 :2 0
4a b4 b6 :3 0 8 :3 0 7 :3 0
13 :3 0 b9 ba 25 :3 0 26 :3 0
bc bd 6 :3 0 1b :3 0 23 :2 0
6 :3 0 c0 c2 0 4d c1 c4
:3 0 b8 c7 c5 0 c8 0 50
0 c6 :2 0 c9 48 ca b7 c9
0 cb 53 0 cc 55 e3 27
:3 0 18 :3 0 28 :3 0 29 :2 0 2a
:4 0 59 d1 d3 :3 0 cf d4 0
de 2b :3 0 2c :3 0 d6 d7 0
2d :2 0 d8 d9 0 de 1a :3 0
2e :2 0 db dc 0 de 5c e0
60 df de :2 0 e1 62 :2 0 e3
0 e3 e2 cc e1 :6 0 e5 5
:2 0 64 e7 1c :3 0 6e e5 :4 0
165 f :3 0 c :3 0 1c :3 0 e8
e9 1d :3 0 1e :3 0 ec ed 0
1f :3 0 f :3 0 7 :3 0 f0 f1
0 ef f2 20 :3 0 21 :4 0 f4
f5 22 :3 0 10 :3 0 f7 f8 18
:3 0 14 :3 0 fa fb 1a :3 0 15
:3 0 fd fe 66 ee 100 :2 0 149
15 :3 0 23 :2 0 24 :2 0 6e 103
105 :3 0 1d :3 0 1e :3 0 107 108
0 1f :3 0 10 :3 0 10a 10b 22
:3 0 13 :3 0 10d 10e 18 :3 0 14
:3 0 110 111 1a :3 0 15 :3 0 113
114 71 109 116 :2 0 118 6c 12e
1d :3 0 1e :3 0 119 11a 0 1f
:3 0 f :3 0 7 :3 0 11d 11e 0
11c 11f 22 :3 0 13 :3 0 121 122
18 :3 0 14 :3 0 124 125 1a :3 0
15 :3 0 127 128 76 11b 12a :2 0
12c 7b 12d 0 12c 0 12f 106
118 0 12f 7d 0 149 15 :3 0
23 :2 0 24 :2 0 82 131 133 :3 0
e :3 0 7 :3 0 13 :3 0 136 137
25 :3 0 26 :3 0 139 13a d :3 0
f :3 0 23 :2 0 d :3 0 13d 13f
0 85 13e 141 :3 0 135 144 142
0 145 0 88 0 143 :2 0 146
80 147 134 146 0 148 8b 0
149 8d 160 27 :3 0 18 :3 0 28
:3 0 29 :2 0 2f :4 0 91 14e 150
:3 0 14c 151 0 15b 2b :3 0 2c
:3 0 153 154 0 2d :2 0 155 156
0 15b 1a :3 0 2e :2 0 158 159
0 15b 94 15d 98 15c 15b :2 0
15e 9a :2 0 160 0 160 15f 149
15e :6 0 162 7 :2 0 9c 164 1c
:3 0 eb 162 :4 0 165 9e 16e 27
:4 0 169 a1 16b a3 16a 169 :2 0
16c a5 :2 0 16e 0 16e 16d 165
16c :6 0 16f 1 5d 69 16e 388
:2 0 30 :a 0 382 9 :3 0 1b8 1b9
a9 a7 16 :3 0 31 :7 0 174 173
:3 0 33 :2 0 ad 176 :2 0 382 171
178 :2 0 11 :3 0 33 :2 0 ab 17a
17c :6 0 17f 17d 0 380 32 :6 0
33 :2 0 b1 11 :3 0 af 181 183
:6 0 186 184 0 380 34 :6 0 33
:2 0 b5 11 :3 0 b3 188 18a :6 0
18d 18b 0 380 35 :6 0 24 :2 0
b9 11 :3 0 b7 18f 191 :6 0 194
192 0 380 36 :6 0 33 :2 0 bb
16 :3 0 196 :7 0 19a 197 198 380
37 :6 0 24 :2 0 bf 11 :3 0 bd
19c 19e :6 0 1a1 19f 0 380 38
:6 0 1a8 1a9 0 c1 16 :3 0 1a3
:7 0 1a7 1a4 1a5 380 39 :6 0 2b
:3 0 3a :3 0 1aa 1ac :2 0 367 0
3b :3 0 3c :3 0 1ad 1ae 0 31
:3 0 2b :3 0 3d :3 0 1b1 1b2 0
3e :4 0 3e :4 0 c3 1af 1b6 :2 0
367 f :3 0 c :3 0 1c :3 0 3b
:3 0 3f :3 0 1bc 1bd 0 40 :2 0
41 :4 0 f :3 0 d :3 0 1c1 1c2
0 c8 1be 1c4 :2 0 203 42 :3 0
43 :2 0 44 :2 0 1c :3 0 1c7 1c8
0 1c6 1ca 1d :3 0 1e :3 0 1cc
1cd 0 f :3 0 7 :3 0 1cf 1d0
0 21 :4 0 34 :3 0 36 :3 0 37
:3 0 cc 1ce 1d6 :2 0 1df 45 :3 0
37 :3 0 23 :2 0 24 :2 0 d4 1da
1dc :4 0 1dd :3 0 1df d7 1e1 1c
:3 0 1cb 1df :4 0 203 37 :3 0 23
:2 0 24 :2 0 da 1e3 1e5 :3 0 1e6
:2 0 1d :3 0 1e :3 0 1e8 1e9 0
34 :3 0 35 :3 0 38 :3 0 39 :3 0
dd 1ea 1ef :2 0 1f1 d2 201 3b
:3 0 3f :3 0 1f2 1f3 0 24 :2 0
46 :4 0 f :3 0 d :3 0 1f7 1f8
0 e2 1f4 1fa :2 0 1ff 34 :4 0
1fc 1fd 0 1ff e6 200 0 1ff
0 202 1e7 1f1 0 202 e9 0
203 ec 23d 27 :3 0 3b :3 0 3f
:3 0 206 207 0 24 :2 0 47 :4 0
f :3 0 d :3 0 20b 20c 0 f0
208 20e :2 0 238 3b :3 0 3f :3 0
210 211 0 24 :2 0 48 :4 0 28
:3 0 f4 212 216 :2 0 238 3b :3 0
3f :3 0 218 219 0 24 :2 0 49
:4 0 37 :3 0 f8 21a 21e :2 0 238
3b :3 0 3f :3 0 220 221 0 24
:2 0 4a :4 0 36 :3 0 fc 222 226
:2 0 238 3b :3 0 3f :3 0 228 229
0 24 :2 0 4b :4 0 39 :3 0 100
22a 22e :2 0 238 3b :3 0 3f :3 0
230 231 0 24 :2 0 4c :4 0 38
:3 0 104 232 236 :2 0 238 108 23a
10f 239 238 :2 0 23b 111 :2 0 23d
0 23d 23c 203 23b :6 0 289 a
:2 0 35 :3 0 9 :2 0 113 240 241
:3 0 242 :2 0 e :3 0 7 :3 0 35
:3 0 245 246 25 :3 0 26 :3 0 248
249 d :3 0 f :3 0 23 :2 0 d
:3 0 24c 24e 0 117 24d 250 :3 0
244 253 251 0 254 0 11a 0
252 :2 0 274 4d :4 0 255 :2 0 23
:2 0 24 :2 0 11d 257 259 :3 0 3b
:3 0 3f :3 0 25b 25c 0 24 :2 0
4e :4 0 f :3 0 d :3 0 260 261
0 120 25d 263 :2 0 265 115 272
3b :3 0 3f :3 0 266 267 0 40
:2 0 4f :4 0 f :3 0 d :3 0 26b
26c 0 124 268 26e :2 0 270 128
271 0 270 0 273 25a 265 0
273 12a 0 274 12d 275 243 274
0 276 130 0 289 35 :4 0 277
278 0 289 34 :4 0 27a 27b 0
289 36 :4 0 27d 27e 0 289 38
:4 0 280 281 0 289 37 :3 0 24
:2 0 283 284 0 289 39 :3 0 24
:2 0 286 287 0 289 132 28b 1c
:3 0 1bb 289 :4 0 367 a :3 0 5
:3 0 1c :3 0 28c 28d 3b :3 0 3f
:3 0 290 291 0 40 :2 0 50 :4 0
a :3 0 6 :3 0 295 296 0 13b
292 298 :2 0 2d4 42 :3 0 43 :2 0
44 :2 0 1c :3 0 29b 29c 0 29a
29e 1d :3 0 1e :3 0 2a0 2a1 0
a :3 0 7 :3 0 2a3 2a4 0 21
:4 0 34 :3 0 36 :3 0 37 :3 0 13f
2a2 2aa :2 0 2b3 45 :3 0 37 :3 0
23 :2 0 24 :2 0 147 2ae 2b0 :4 0
2b1 :3 0 2b3 14a 2b5 1c :3 0 29f
2b3 :4 0 2d4 37 :3 0 23 :2 0 24
:2 0 14d 2b7 2b9 :3 0 2ba :2 0 1d
:3 0 1e :3 0 2bc 2bd 0 34 :3 0
35 :3 0 38 :3 0 39 :3 0 150 2be
2c3 :2 0 2c5 145 2d2 3b :3 0 3f
:3 0 2c6 2c7 0 24 :2 0 51 :4 0
a :3 0 6 :3 0 2cb 2cc 0 155
2c8 2ce :2 0 2d0 159 2d1 0 2d0
0 2d3 2bb 2c5 0 2d3 15b 0
2d4 15e 30e 27 :3 0 3b :3 0 3f
:3 0 2d7 2d8 0 24 :2 0 52 :4 0
a :3 0 6 :3 0 2dc 2dd 0 162
2d9 2df :2 0 309 3b :3 0 3f :3 0
2e1 2e2 0 24 :2 0 48 :4 0 28
:3 0 166 2e3 2e7 :2 0 309 3b :3 0
3f :3 0 2e9 2ea 0 24 :2 0 49
:4 0 37 :3 0 16a 2eb 2ef :2 0 309
3b :3 0 3f :3 0 2f1 2f2 0 24
:2 0 4a :4 0 36 :3 0 16e 2f3 2f7
:2 0 309 3b :3 0 3f :3 0 2f9 2fa
0 24 :2 0 4b :4 0 39 :3 0 172
2fb 2ff :2 0 309 3b :3 0 3f :3 0
301 302 0 24 :2 0 4c :4 0 38
:3 0 176 303 307 :2 0 309 17a 30b
181 30a 309 :2 0 30c 183 :2 0 30e
0 30e 30d 2d4 30c :6 0 35a d
:2 0 35 :3 0 9 :2 0 185 311 312
:3 0 313 :2 0 8 :3 0 7 :3 0 35
:3 0 316 317 25 :3 0 26 :3 0 319
31a 6 :3 0 a :3 0 23 :2 0 6
:3 0 31d 31f 0 189 31e 321 :3 0
315 324 322 0 325 0 18c 0
323 :2 0 345 4d :4 0 326 :2 0 23
:2 0 24 :2 0 18f 328 32a :3 0 3b
:3 0 3f :3 0 32c 32d 0 24 :2 0
53 :4 0 a :3 0 6 :3 0 331 332
0 192 32e 334 :2 0 336 187 343
3b :3 0 3f :3 0 337 338 0 40
:2 0 4f :4 0 a :3 0 6 :3 0 33c
33d 0 196 339 33f :2 0 341 19a
342 0 341 0 344 32b 336 0
344 19c 0 345 19f 346 314 345
0 347 1a2 0 35a 35 :4 0 348
349 0 35a 34 :4 0 34b 34c 0
35a 36 :4 0 34e 34f 0 35a 38
:4 0 351 352 0 35a 37 :3 0 24
:2 0 354 355 0 35a 39 :3 0 24
:2 0 357 358 0 35a 1a4 35c 1c
:3 0 28f 35a :4 0 367 3b :3 0 54
:3 0 35d 35e :2 0 35f 360 :2 0 367
3b :3 0 55 :3 0 362 363 :2 0 364
365 :2 0 367 1ad 381 27 :3 0 3b
:3 0 3f :3 0 36a 36b 0 24 :2 0
56 :4 0 28 :3 0 1b4 36c 370 :2 0
37c 3b :3 0 54 :3 0 372 373 :2 0
374 375 :2 0 37c 3b :3 0 55 :3 0
377 378 :2 0 379 37a :2 0 37c 1b8
37e 1bc 37d 37c :2 0 37f 1be :2 0
381 1c0 381 380 367 37f :6 0 382
1 171 178 381 388 :3 0 387 0
387 :3 0 387 388 385 386 :6 0 389
0 1c8 0 4 387 38b :2 0 2
389 38c :6 0
1d3
2
:3 0 2 a b 1 d 1 10
1 17 1 1d 2 29 2a 1
2c 1 2f 1 36 1 3c 1
45 1 43 1 4c 1 4a 1
53 1 51 1 58 1 5e 1
63 2 62 67 5 76 79 7c
7f 82 1 9a 2 85 87 4
8f 92 95 98 4 a3 a6 a9
ac 1 ae 2 b1 b0 1 c8
2 b3 b5 2 bf c3 2 bb
be 1 ca 3 84 b2 cb 2
d0 d2 3 d5 da dd 1 ce
1 e0 1 e3 5 f3 f6 f9
fc ff 1 117 2 102 104 4
10c 10f 112 115 4 120 123 126
129 1 12b 2 12e 12d 1 145
2 130 132 2 13c 140 2 138
13b 1 147 3 101 12f 148 2
14d 14f 3 152 157 15a 1 14b
1 15d 1 160 2 e7 164 1
168 1 167 1 16b 1 172 1
175 1 17b 1 177 1 182 1
180 1 189 1 187 1 190 1
18e 1 195 1 19d 1 19b 1
1a2 4 1b0 1b3 1b4 1b5 3 1bf
1c0 1c3 5 1d1 1d2 1d3 1d4 1d5
1 1f0 2 1d9 1db 2 1d7 1de
2 1e2 1e4 4 1eb 1ec 1ed 1ee
3 1f5 1f6 1f9 2 1fb 1fe 2
201 200 3 1c5 1e1 202 3 209
20a 20d 3 213 214 215 3 21b
21c 21d 3 223 224 225 3 22b
22c 22d 3 233 234 235 6 20f
217 21f 227 22f 237 1 205 1
23a 1 23f 1 264 2 24b 24f
2 247 24a 2 256 258 3 25e
25f 262 3 269 26a 26d 1 26f
2 272 271 2 254 273 1 275
8 23d 276 279 27c 27f 282 285
288 3 293 294 297 5 2a5 2a6
2a7 2a8 2a9 1 2c4 2 2ad 2af
2 2ab 2b2 2 2b6 2b8 4 2bf
2c0 2c1 2c2 3 2c9 2ca 2cd 1
2cf 2 2d2 2d1 3 299 2b5 2d3
3 2da 2db 2de 3 2e4 2e5 2e6
3 2ec 2ed 2ee 3 2f4 2f5 2f6
3 2fc 2fd 2fe 3 304 305 306
6 2e0 2e8 2f0 2f8 300 308 1
2d6 1 30b 1 310 1 335 2
31c 320 2 318 31b 2 327 329
3 32f 330 333 3 33a 33b 33e
1 340 2 343 342 2 325 344
1 346 8 30e 347 34a 34d 350
353 356 359 6 1ab 1b7 28b 35c
361 366 3 36d 36e 36f 3 371
376 37b 1 369 1 37e 7 17e
185 18c 193 199 1a0 1a6 a 18
22 37 41 48 4f 56 5b 16f
382
1
4
0
38b
0
1
14
f
1b
0 1 1 1 4 5 4 7
1 9 a b 9 d e 0
0 0 0 0
4 0 1
172 9 0
187 9 0
1b8 a 0
18e 9 0
e8 7 0
5e 4 0
3c 1 0
177 9 0
19b 9 0
1a2 9 0
51 1 0
6 1 2
63 4 0
5d 1 4
6b 5 0
43 1 0
29a f 0
1c6 c 0
195 9 0
28c d 0
1d 1 0
25 1 3
180 9 0
171 1 9
58 1 0
4a 1 0
0


/
