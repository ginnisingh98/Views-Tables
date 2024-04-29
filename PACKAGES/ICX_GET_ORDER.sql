--------------------------------------------------------
--  DDL for Package ICX_GET_ORDER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_GET_ORDER" AUTHID CURRENT_USER AS
/* $Header: ICXGETOS.pls 115.1 99/07/17 03:17:34 porting ship $ */

function GET_PO_NUMBER (IN_HEAD_ID number) return VARCHAR2;
 pragma restrict_references (GET_PO_NUMBER,WNDS,RNPS,WNPS);
function GET_REQ_NUMBER (IN_HEAD_ID number) return VARCHAR2;
 pragma restrict_references (GET_REQ_NUMBER,WNDS,RNPS,WNPS);
function GET_SO_NUMBER (IN_HEAD_ID number) return VARCHAR2;
 pragma restrict_references (GET_SO_NUMBER,WNDS,RNPS,WNPS);
function GET_WIP_NUMBER (IN_HEAD_ID number) return VARCHAR2;
 pragma restrict_references (GET_WIP_NUMBER,WNDS,RNPS,WNPS);
END ICX_GET_ORDER;

 

/
