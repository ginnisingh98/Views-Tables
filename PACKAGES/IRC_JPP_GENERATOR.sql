--------------------------------------------------------
--  DDL for Package IRC_JPP_GENERATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IRC_JPP_GENERATOR" AUTHID CURRENT_USER as
/* $Header: irjppgen.pkh 120.0.12010000.2 2010/04/08 14:16:51 amikukum ship $ */
function generateJPP(p_recruitment_activity_id in number
                    ,p_sender_id in number
                    ,p_stylesheet varchar2 default null) return clob;

procedure show_posting(p in number
                      ,u in number
                      ,s in varchar2 default null);

function getXMLDataFromDB(p_recruitment_activity_id in number
                             ,p_sender_id in number) return clob;
end;

/
