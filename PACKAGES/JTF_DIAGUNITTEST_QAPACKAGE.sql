--------------------------------------------------------
--  DDL for Package JTF_DIAGUNITTEST_QAPACKAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_DIAGUNITTEST_QAPACKAGE" AUTHID CURRENT_USER AS
/* $Header: jtfdiagadptuqa_s.pls 120.2 2005/08/13 01:25:02 minxu noship $ */

    PROCEDURE init;
    PROCEDURE cleanup;
    PROCEDURE testPower;
    PROCEDURE testExp;
    PROCEDURE getComponentName(str OUT NOCOPY VARCHAR2);
    PROCEDURE getTestName(str OUT NOCOPY VARCHAR2);
    PROCEDURE getTestDesc(str OUT NOCOPY VARCHAR2);

END JTF_DIAGUNITTEST_QAPACKAGE;


 

/
