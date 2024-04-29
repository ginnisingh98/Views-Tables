--------------------------------------------------------
--  DDL for Package GL_AUTO_ALLOC_WF_CUST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GL_AUTO_ALLOC_WF_CUST_PKG" AUTHID CURRENT_USER AS
/*  $Header: glcwfals.pls 120.2 2002/11/11 23:54:21 djogg ship $  */

 -- Used in GL Customizable workflow processes
procedure dummy1(p_item_type      IN VARCHAR2,
                p_item_key       IN VARCHAR2,
                p_actid          IN NUMBER,
                p_funcmode        IN VARCHAR2,
                p_result         OUT NOCOPY VARCHAR2);

 -- Used in project Customizable workflow processes
procedure dummy2(p_item_type      IN VARCHAR2,
                p_item_key       IN VARCHAR2,
                p_actid          IN NUMBER,
                p_funcmode        IN VARCHAR2,
                p_result         OUT NOCOPY VARCHAR2);


End GL_AUTO_ALLOC_WF_CUST_PKG;

 

/
