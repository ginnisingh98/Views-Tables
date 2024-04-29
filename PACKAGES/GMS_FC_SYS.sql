--------------------------------------------------------
--  DDL for Package GMS_FC_SYS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_FC_SYS" AUTHID CURRENT_USER AS
-- $Header: gmsfcsys.pls 120.0 2005/05/29 11:38:40 appldev noship $

-----------------------------------------------------------------------------------------------
-- Procedure to Fundscheck Encumbrance Items
------------------------------------------------------------------------------------------------
Procedure funds_check_enc(errbuf        OUT NOCOPY     VARCHAR2,
                          retcode       OUT NOCOPY     VARCHAR2,
                          p_enc_group   IN      VARCHAR2 default null,
			  p_project_id		NUMBER	 default null,
			  p_end_date		DATE	 default null,
			  p_org_id		NUMBER	 default null);

-----------------------------------------------------------------------------------------------
-- Procedure to submit Fundscheck Encumbrance Items called from GMSTRENE.fmb
------------------------------------------------------------------------------------------------
function submit_funds_check_enc(
                          p_enc_group   IN      VARCHAR2 default null,
			  p_project_id		NUMBER	 default null,
			  p_end_date		DATE	 default null,
			  p_org_id		NUMBER	 default null) return NUMBER;

END GMS_FC_SYS;

 

/
