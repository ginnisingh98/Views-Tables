--------------------------------------------------------
--  DDL for Package JTM_CHECK_ACC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTM_CHECK_ACC_PKG" AUTHID CURRENT_USER as
/* $Header: jtmchkas.pls 120.1 2005/08/24 02:08:11 saradhak noship $ */

TYPE errTab is table of varchar2(100) index by binary_integer;
TYPE accTab is table of varchar2(100) index by binary_integer;

--Check weather profile_option, profile_option_value access tables get populated
FUNCTION check_profile_acc(p_errtable  IN OUT NOCOPY errTab) RETURN BOOLEAN;

--Check weather jtf related access tables get populated
FUNCTION check_jtf_acc(p_errtable  IN OUT NOCOPY errTab) RETURN BOOLEAN;

end JTM_Check_Acc_PKG;

 

/
