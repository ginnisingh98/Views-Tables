--------------------------------------------------------
--  DDL for Package QPR_COPY_PRICE_PLAN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QPR_COPY_PRICE_PLAN" AUTHID CURRENT_USER AS
/* $Header: QPRUCPPS.pls 120.0 2007/10/11 13:09:52 agbennet noship $ */

procedure copy_price_plan( errbuf out nocopy varchar2,
                          retcode out nocopy varchar2,
                          p_from_pp_id in number,
                          p_new_aw_name in varchar2,
                          p_copy_det_frm_tmpl in varchar2);

END;


/
