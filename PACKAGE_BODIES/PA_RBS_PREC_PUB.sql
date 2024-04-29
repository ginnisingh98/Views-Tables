--------------------------------------------------------
--  DDL for Package Body PA_RBS_PREC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RBS_PREC_PUB" AS
/* $Header: PARBSPRB.pls 120.0 2005/05/29 14:46:24 appldev noship $ */

---------------------------------------------------
--calculate resource class precedence for each rule
---------------------------------------------------
FUNCTION	calc_rc_precedence
		(
		resource_type_id	number,
		res_class_id		number
		)
		RETURN NUMBER
IS
TYPE res_type_rec IS RECORD
(res_type_id	number,
per_rc_prec	number,
equip_rc_prec	number,
mat_rc_prec	number,
fin_rc_prec	number);
TYPE res_type_rec_tab IS TABLE OF res_type_rec INDEX BY BINARY_INTEGER;

res_type_rec_t	res_type_rec_tab;

BEGIN

--below precedence values for 16 resource types are taken from RBS FD

res_type_rec_t(1).res_type_id := 1;
res_type_rec_t(1).per_rc_prec := 2;
res_type_rec_t(1).equip_rc_prec := 2;
res_type_rec_t(1).mat_rc_prec := 2;
res_type_rec_t(1).fin_rc_prec := 2;

res_type_rec_t(2).res_type_id := 2;
res_type_rec_t(2).per_rc_prec := 4;
res_type_rec_t(2).equip_rc_prec := 4;
res_type_rec_t(2).mat_rc_prec := 4;
res_type_rec_t(2).fin_rc_prec := 4;

res_type_rec_t(3).res_type_id := 3;
res_type_rec_t(3).per_rc_prec := 1;
res_type_rec_t(3).equip_rc_prec := 1;
res_type_rec_t(3).mat_rc_prec := 1;
res_type_rec_t(3).fin_rc_prec := 1;

res_type_rec_t(4).res_type_id := 4;
res_type_rec_t(4).per_rc_prec := 10;
res_type_rec_t(4).equip_rc_prec := 10;
res_type_rec_t(4).mat_rc_prec := 10;
res_type_rec_t(4).fin_rc_prec := 10;

res_type_rec_t(5).res_type_id := 5;
res_type_rec_t(5).per_rc_prec := 11;
res_type_rec_t(5).equip_rc_prec := 11;
res_type_rec_t(5).mat_rc_prec := 11;
res_type_rec_t(5).fin_rc_prec := 11;

res_type_rec_t(6).res_type_id := 6;
res_type_rec_t(6).per_rc_prec := 9;
res_type_rec_t(6).equip_rc_prec := 9;
res_type_rec_t(6).mat_rc_prec := 9;
res_type_rec_t(6).fin_rc_prec := 9;

res_type_rec_t(7).res_type_id := 7;
res_type_rec_t(7).per_rc_prec := 8;
res_type_rec_t(7).equip_rc_prec := 8;
res_type_rec_t(7).mat_rc_prec := 8;
res_type_rec_t(7).fin_rc_prec := 8;

res_type_rec_t(8).res_type_id := 8;
res_type_rec_t(8).per_rc_prec := 5;
res_type_rec_t(8).equip_rc_prec := 5;
res_type_rec_t(8).mat_rc_prec := 5;
res_type_rec_t(8).fin_rc_prec := 5;

res_type_rec_t(9).res_type_id := 9;
res_type_rec_t(9).per_rc_prec := 6;
res_type_rec_t(9).equip_rc_prec := 6;
res_type_rec_t(9).mat_rc_prec := 6;
res_type_rec_t(9).fin_rc_prec := 6;

res_type_rec_t(10).res_type_id := 10;
res_type_rec_t(10).per_rc_prec := 13;
res_type_rec_t(10).equip_rc_prec := 13;
res_type_rec_t(10).mat_rc_prec := 15;
res_type_rec_t(10).fin_rc_prec := 15;

res_type_rec_t(11).res_type_id := 11;
res_type_rec_t(11).per_rc_prec := 14;
res_type_rec_t(11).equip_rc_prec := 14;
res_type_rec_t(11).mat_rc_prec := 14;
res_type_rec_t(11).fin_rc_prec := 14;

res_type_rec_t(12).res_type_id := 12;
res_type_rec_t(12).per_rc_prec := 3;
res_type_rec_t(12).equip_rc_prec := 3;
res_type_rec_t(12).mat_rc_prec := 3;
res_type_rec_t(12).fin_rc_prec := 3;

res_type_rec_t(13).res_type_id := 13;
res_type_rec_t(13).per_rc_prec := 16;
res_type_rec_t(13).equip_rc_prec := 16;
res_type_rec_t(13).mat_rc_prec := 16;
res_type_rec_t(13).fin_rc_prec := 16;

res_type_rec_t(14).res_type_id := 14;
res_type_rec_t(14).per_rc_prec := 12;
res_type_rec_t(14).equip_rc_prec := 12;
res_type_rec_t(14).mat_rc_prec := 12;
res_type_rec_t(14).fin_rc_prec := 12;

res_type_rec_t(15).res_type_id := 15;
res_type_rec_t(15).per_rc_prec := 7;
res_type_rec_t(15).equip_rc_prec := 7;
res_type_rec_t(15).mat_rc_prec := 7;
res_type_rec_t(15).fin_rc_prec := 7;

res_type_rec_t(16).res_type_id := 16;
res_type_rec_t(16).per_rc_prec := 15;
res_type_rec_t(16).equip_rc_prec := 15;
res_type_rec_t(16).mat_rc_prec := 13;
res_type_rec_t(16).fin_rc_prec := 13;


FOR i IN 1..16 LOOP
	IF res_type_rec_t(i).res_type_id = resource_type_id THEN
		IF res_class_id = 1 THEN
			RETURN res_type_rec_t(i).per_rc_prec;
		ELSIF res_class_id = 2 THEN
			RETURN res_type_rec_t(i).equip_rc_prec;
		ELSIF res_class_id = 3 THEN
			RETURN res_type_rec_t(i).mat_rc_prec;
		ELSIF res_class_id = 4 THEN
			RETURN res_type_rec_t(i).fin_rc_prec;
		END IF;
	END IF;
END LOOP;

-- added for custom nodes
	IF resource_type_id = 18 THEN
		IF res_class_id = 1 THEN
			RETURN 20;  --bug#3908476
		ELSIF res_class_id = 2 THEN
			RETURN 20;  --bug#3908476
		ELSIF res_class_id = 3 THEN
			RETURN 20;  --bug#3908476
		ELSIF res_class_id = 4 THEN
			RETURN 20;  --bug#3908476
		END IF;
	END IF;

END;

FUNCTION	calc_rule_precedence
		(
		rule_type_id	varchar,
		res_class_id		number
		)
		RETURN NUMBER
IS
TYPE res_type_rec IS RECORD
(rule_type      varchar(150),
per_rc_prec	number,
equip_rc_prec	number,
mat_rc_prec	number,
fin_rc_prec	number);
TYPE res_type_rec_tab IS TABLE OF res_type_rec INDEX BY BINARY_INTEGER;

res_type_rec_t	res_type_rec_tab;

BEGIN

--below precedence values for 16 resource types are taken from RBS FD

res_type_rec_t(1).rule_type :='BML';
res_type_rec_t(1).per_rc_prec := 2;
res_type_rec_t(1).equip_rc_prec := 2;
res_type_rec_t(1).mat_rc_prec := 2;
res_type_rec_t(1).fin_rc_prec := 2;

res_type_rec_t(2).rule_type := 'BME';
res_type_rec_t(2).per_rc_prec := 4;
res_type_rec_t(2).equip_rc_prec := 4;
res_type_rec_t(2).mat_rc_prec := 4;
res_type_rec_t(2).fin_rc_prec := 4;

res_type_rec_t(3).rule_type := 'PER';
res_type_rec_t(3).per_rc_prec := 1;
res_type_rec_t(3).equip_rc_prec := 1;
res_type_rec_t(3).mat_rc_prec := 1;
res_type_rec_t(3).fin_rc_prec := 1;

res_type_rec_t(4).rule_type := 'EVT';
res_type_rec_t(4).per_rc_prec := 10;
res_type_rec_t(4).equip_rc_prec := 10;
res_type_rec_t(4).mat_rc_prec := 10;
res_type_rec_t(4).fin_rc_prec := 10;

res_type_rec_t(5).rule_type := 'EXC';
res_type_rec_t(5).per_rc_prec := 11;
res_type_rec_t(5).equip_rc_prec := 11;
res_type_rec_t(5).mat_rc_prec := 11;
res_type_rec_t(5).fin_rc_prec := 11;

res_type_rec_t(6).rule_type := 'EXT';
res_type_rec_t(6).per_rc_prec := 9;
res_type_rec_t(6).equip_rc_prec := 9;
res_type_rec_t(6).mat_rc_prec := 9;
res_type_rec_t(6).fin_rc_prec := 9;

res_type_rec_t(7).rule_type := 'ITC';
res_type_rec_t(7).per_rc_prec := 8;
res_type_rec_t(7).equip_rc_prec := 8;
res_type_rec_t(7).mat_rc_prec := 8;
res_type_rec_t(7).fin_rc_prec := 8;

res_type_rec_t(8).rule_type := 'ITM';
res_type_rec_t(8).per_rc_prec := 5;
res_type_rec_t(8).equip_rc_prec := 5;
res_type_rec_t(8).mat_rc_prec := 5;
res_type_rec_t(8).fin_rc_prec := 5;

res_type_rec_t(9).rule_type := 'JOB';
res_type_rec_t(9).per_rc_prec := 6;
res_type_rec_t(9).equip_rc_prec := 6;
res_type_rec_t(9).mat_rc_prec := 6;
res_type_rec_t(9).fin_rc_prec := 6;

res_type_rec_t(10).rule_type := 'ORG';
res_type_rec_t(10).per_rc_prec := 13;
res_type_rec_t(10).equip_rc_prec := 13;
res_type_rec_t(10).mat_rc_prec := 15;
res_type_rec_t(10).fin_rc_prec := 15;

res_type_rec_t(11).rule_type := 'PTP';
res_type_rec_t(11).per_rc_prec := 14;
res_type_rec_t(11).equip_rc_prec := 14;
res_type_rec_t(11).mat_rc_prec := 14;
res_type_rec_t(11).fin_rc_prec := 14;

res_type_rec_t(12).rule_type := 'NLR';
res_type_rec_t(12).per_rc_prec := 3;
res_type_rec_t(12).equip_rc_prec := 3;
res_type_rec_t(12).mat_rc_prec := 3;
res_type_rec_t(12).fin_rc_prec := 3;

res_type_rec_t(13).rule_type := 'RES';
res_type_rec_t(13).per_rc_prec := 16;
res_type_rec_t(13).equip_rc_prec := 16;
res_type_rec_t(13).mat_rc_prec := 16;
res_type_rec_t(13).fin_rc_prec := 16;

res_type_rec_t(14).rule_type := 'RVC';
res_type_rec_t(14).per_rc_prec := 12;
res_type_rec_t(14).equip_rc_prec := 12;
res_type_rec_t(14).mat_rc_prec := 12;
res_type_rec_t(14).fin_rc_prec := 12;

res_type_rec_t(15).rule_type := 'ROL';
res_type_rec_t(15).per_rc_prec := 7;
res_type_rec_t(15).equip_rc_prec := 7;
res_type_rec_t(15).mat_rc_prec := 7;
res_type_rec_t(15).fin_rc_prec := 7;

res_type_rec_t(16).rule_type :='SUP';
res_type_rec_t(16).per_rc_prec := 15;
res_type_rec_t(16).equip_rc_prec := 15;
res_type_rec_t(16).mat_rc_prec := 13;
res_type_rec_t(16).fin_rc_prec := 13;


FOR i IN 1..16 LOOP
	IF res_type_rec_t(i).rule_type = rule_type_id THEN
		IF res_class_id = 1 THEN
			RETURN res_type_rec_t(i).per_rc_prec;
		ELSIF res_class_id = 2 THEN
			RETURN res_type_rec_t(i).equip_rc_prec;
		ELSIF res_class_id = 3 THEN
			RETURN res_type_rec_t(i).mat_rc_prec;
		ELSIF res_class_id = 4 THEN
			RETURN res_type_rec_t(i).fin_rc_prec;
		END IF;
	END IF;
END LOOP;

-- added for custom nodes
	IF rule_type_id in ('CU1','CU2','CU3','CU4','CU5') THEN
		IF res_class_id = 1 THEN
			RETURN 20;  --bug#3908476
		ELSIF res_class_id = 2 THEN
			RETURN 20;  --bug#3908476
		ELSIF res_class_id = 3 THEN
			RETURN 20;  --bug#3908476
		ELSIF res_class_id = 4 THEN
			RETURN 20;  --bug#3908476
		END IF;
	END IF;

END;

END; --end package PA_RBS_PREC_PUB

/
