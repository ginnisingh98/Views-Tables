--------------------------------------------------------
--  DDL for Package HRI_OPL_SPRTN_RSNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HRI_OPL_SPRTN_RSNS" AUTHID CURRENT_USER AS
/* $Header: hriosprn.pkh 115.2 2002/12/06 15:15:00 cbridge noship $ */

PROCEDURE load_sprtn_rsns_tab;

PROCEDURE populate_sprtn_rsns(Errbuf       in out nocopy  Varchar2,
                              Retcode      in out nocopy Varchar2);

END hri_opl_sprtn_rsns;

 

/
