--------------------------------------------------------
--  DDL for Package EDR_GENERAL_SUBS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDR_GENERAL_SUBS" AUTHID CURRENT_USER AS
/*  $Header: EDRGSUBS.pls 120.0.12000000.1 2007/01/18 05:54:01 appldev ship $ */

PROCEDURE UPLOAD_STYLESHEET(p_itemtype VARCHAR2,
  				   p_itemkey VARCHAR2,
				   p_actid NUMBER,
				   p_funcmode VARCHAR2,
				   p_resultout OUT NOCOPY VARCHAR2);

END EDR_GENERAL_SUBS;

 

/
