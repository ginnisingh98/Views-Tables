--------------------------------------------------------
--  DDL for Package ZPB_WF_ERROR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_WF_ERROR" AUTHID CURRENT_USER AS
/* $Header: zpbwferror.pls 120.1.12010.2 2006/08/03 18:46:22 appldev noship $  */


PROCEDURE SET_ERROR(itemtype in VARCHAR2,
                    itemkey  in VARCHAR2,
                    actid    in NUMBER,
                    funcmode in VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2);

PROCEDURE SET_CONC_ERROR(itemtype in VARCHAR2,
                    itemkey  in VARCHAR2,
                    actid    in NUMBER,
                    funcmode in VARCHAR2,
                    resultout OUT NOCOPY VARCHAR2);

END ZPB_WF_ERROR;

 

/
