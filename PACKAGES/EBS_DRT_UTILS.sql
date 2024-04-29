--------------------------------------------------------
--  DDL for Package EBS_DRT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EBS_DRT_UTILS" AUTHID CURRENT_USER as
/* $Header: ebdrtutl.pkh 120.0.12010000.2 2020/03/13 11:18:08 ktithy noship $ */

PROCEDURE ENTITY_CHECK_CONSTRAINTS
    (CHK_DRC_BATCH IN  EBS_DRT_REMOVAL_REC);

PROCEDURE ENTITY_REMOVE
    (CHK_DRC_BATCH IN  EBS_DRT_REMOVAL_REC,
			OVERRIDE_WARNINGS IN varchar2 DEFAULT 'N');

END EBS_DRT_UTILS;

/
