--------------------------------------------------------
--  DDL for Package OE_BULK_ACK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_BULK_ACK_PVT" AUTHID CURRENT_USER AS
/* $Header: OEBVACKS.pls 120.0 2005/06/01 03:06:19 appldev noship $ */

FUNCTION Get_Address_ID(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN NUMBER;

FUNCTION Get_Address1(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Address2(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Address3(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Address4(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_State(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_City(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Zip(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Country(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_County(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Province(p_key              IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_Location(p_key          IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_EDI_Location(p_key          IN NUMBER
                     ,p_site_use_code    IN VARCHAR2)
RETURN VARCHAR2;

PROCEDURE Process_Acknowledgments
        (p_batch_id            IN NUMBER
        ,x_return_status       OUT NOCOPY /* file.sql.39 change */ VARCHAR2);

END OE_BULK_ACK_PVT;

 

/
