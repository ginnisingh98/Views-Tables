--------------------------------------------------------
--  DDL for Package OKE_CONTRACT_PRINTING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKE_CONTRACT_PRINTING_PKG" AUTHID CURRENT_USER AS
/* $Header: OKEKCPPS.pls 115.1 2003/10/14 01:25:17 tweichen noship $ */

   PROCEDURE get_item_master_org(p_header_id    IN             NUMBER
                                ,x_org_name     OUT NOCOPY     VARCHAR2);



   PROCEDURE get_partyOrContact_name(p_jtot_object1_code    IN             VARCHAR2
                                    ,p_object1_id1          IN             VARCHAR2
                                    ,p_object1_id2          IN             VARCHAR2
                                    ,p_name                 OUT NOCOPY     VARCHAR2);

   PROCEDURE get_article_info(p_cat_type      IN             VARCHAR2
                             ,p_sav_sae_id    IN             NUMBER
                             ,p_sbt_code      IN             VARCHAR2
                             ,p_article_name  IN             VARCHAR2
                             ,x_sbt_code      OUT  NOCOPY    VARCHAR2
                             ,x_article_name  OUT  NOCOPY    VARCHAR2
                             ,x_subject_name  OUT  NOCOPY    VARCHAR2);


    PROCEDURE get_article_application(p_id                    IN               NUMBER
                                    ,p_version                IN               NUMBER
                                    ,p_cat_type               IN               VARCHAR2
                                    ,p_sav_sae_id             IN               NUMBER
                                    ,p_sav_sav_release        IN               VARCHAR2
                                    ,x_comments               OUT    NOCOPY    VARCHAR2
                                    ,x_lines_applied          OUT    NOCOPY    VARCHAR2
                                    ,x_text                   OUT    NOCOPY    CLOB);

   PROCEDURE convert_date(p_date     IN             DATE
                         ,x_date     OUT  NOCOPY    VARCHAR2);

   PROCEDURE get_line_number(p_id            IN           NUMBER
                            ,p_version       IN           NUMBER
                            ,p_line_id       IN           NUMBER
                            ,x_line_number   OUT  NOCOPY  VARCHAR2);


END OKE_CONTRACT_PRINTING_PKG;


 

/
