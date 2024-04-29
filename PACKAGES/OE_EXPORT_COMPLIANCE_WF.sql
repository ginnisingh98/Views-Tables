--------------------------------------------------------
--  DDL for Package OE_EXPORT_COMPLIANCE_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_EXPORT_COMPLIANCE_WF" AUTHID CURRENT_USER as
/* $Header: OEXWECSS.pls 120.0.12010000.2 2009/09/25 07:01:39 kshashan ship $ */

PROCEDURE ECS_Request(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY /* file.sql.39 change */ varchar2);

-- Below API added for Bug 8762350
PROCEDURE Update_Screening_Results(
    itemtype IN VARCHAR2,
    itemkey IN VARCHAR2,
    actid IN NUMBER,
    funcmode IN VARCHAR2,
    resultout IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2);
END OE_EXPORT_COMPLIANCE_WF;

/
