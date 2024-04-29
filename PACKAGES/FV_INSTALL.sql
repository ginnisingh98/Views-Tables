--------------------------------------------------------
--  DDL for Package FV_INSTALL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_INSTALL" AUTHID CURRENT_USER AS
--$Header: FVXINSTS.pls 120.4.12000000.1 2007/01/18 13:48:13 appldev ship $     |

FUNCTION enabled(x_org_id NUMBER) RETURN BOOLEAN;
FUNCTION enabled RETURN BOOLEAN;
FUNCTION enabled_yn RETURN varchar2;

END fv_install;

 

/
