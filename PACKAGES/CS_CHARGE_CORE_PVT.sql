--------------------------------------------------------
--  DDL for Package CS_CHARGE_CORE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_CHARGE_CORE_PVT" AUTHID CURRENT_USER AS
/*$Header: csxchcrs.pls 115.10 2004/05/19 22:14:48 mviswana ship $*/


PROCEDURE Get_Source_Id(
                p_source_code       IN   VARCHAR2,
                p_source_number     IN   VARCHAR2,
                p_org_id            IN   NUMBER,
                x_source_id        OUT NOCOPY   NUMBER,
                p_return_status    OUT NOCOPY   VARCHAR2) ;

PROCEDURE Get_Invoice_details(
                p_order_header_id   IN   NUMBER,
                p_order_line_id     IN   NUMBER,
                x_invoice_number   OUT NOCOPY   VARCHAR2,
                x_invoice_date     OUT NOCOPY   DATE) ;

Procedure default_attributes(p_org OUT NOCOPY  number,
				  x_return_status  OUT NOCOPY varchar2);


Function Get_Ship_To_Site_Id(p_qte_header_id  NUMBER,
					    p_qte_line_id	 NUMBER) return number;

Function Get_Invoice_To_Party_Site_Id(p_qte_header_id NUMBER,
							   p_qte_line_id   NUMBER) return number;

Function Number_Format(p_value_amount IN NUMBER) return VARCHAR2;

Function Get_Value_Name(p_restriction_type    IN VARCHAR2,
                        p_value_object_id     IN NUMBER) return VARCHAR2;

END CS_Charge_Core_PVT ;



 

/
