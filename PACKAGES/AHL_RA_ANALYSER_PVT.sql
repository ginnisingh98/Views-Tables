--------------------------------------------------------
--  DDL for Package AHL_RA_ANALYSER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AHL_RA_ANALYSER_PVT" AUTHID CURRENT_USER AS
/* $Header: AHLVRAAS.pls 120.1 2005/07/07 05:19 sagarwal noship $*/

Type Num15TabType  is table of NUMBER(15)  index by binary_integer ;
Type NumTabType  is table of NUMBER  index by binary_integer ;
Type Varchar1TabType  is table of VARCHAR2(1)  index by binary_integer ;
Type Varchar3TabType  is table of VARCHAR2(3)  index by binary_integer ;
Type Varchar10TabType  is table of VARCHAR2(10)  index by binary_integer ;
Type Varchar30TabType  is table of VARCHAR2(30)  index by binary_integer ;
Type Varchar40TabType  is table of VARCHAR2(40)  index by binary_integer ;
Type Varchar80TabType  is table of VARCHAR2(80)  index by binary_integer ;
Type Varchar150TabType  is table of VARCHAR2(150)  index by binary_integer ;
Type Varchar240TabType  is table of VARCHAR2(240)  index by binary_integer ;
Type DateTabType  is table of DATE index by binary_integer ;

    PROCEDURE PROCESS_RA_DATA (
        p_api_version               IN               NUMBER,
        p_init_msg_list             IN               VARCHAR2  := FND_API.G_FALSE,
        p_commit                    IN               VARCHAR2  := FND_API.G_FALSE,
        p_validation_level          IN               NUMBER    := FND_API.G_VALID_LEVEL_FULL,
        p_module_type               IN               VARCHAR2,
        x_return_status             OUT      NOCOPY  VARCHAR2,
        x_msg_count                 OUT      NOCOPY  NUMBER,
        x_msg_data                  OUT      NOCOPY  VARCHAR2,
        p_start_date                IN               DATE,
        p_end_date                  IN               DATE,
        p_concurrent_flag           IN               VARCHAR2 := 'N',
        x_xml_data                  OUT      NOCOPY  CLOB);

    PROCEDURE RA_ANALYSER_PROCESS (
        errbuf                      OUT      NOCOPY  VARCHAR2,
        retcode                     OUT      NOCOPY  NUMBER,
        p_api_version               IN               NUMBER,
        p_start_date                IN               VARCHAR2,
        p_end_date                  IN               VARCHAR2);

END AHL_RA_ANALYSER_PVT;

 

/
