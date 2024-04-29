--------------------------------------------------------
--  DDL for Package ASG_OA_BASE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASG_OA_BASE" AUTHID CURRENT_USER as
/* $Header: asgoabases.pls 120.2 2005/07/26 01:57:18 ravir noship $ */

--
--    Table handler for CSM_CUSTOMIZATION_VIEWS table.
--
-- HISTORY
--   JUL 20, 2005  yazhang created.

function getRealTime (sec in number) return varchar2;

function getEnabled (code in VARCHAR2,
                    sign1 in number,
                    status_code in varchar,
                    sign2 in number) return varchar2;
end asg_oa_base;


 

/
