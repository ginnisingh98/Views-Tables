--------------------------------------------------------
--  DDL for Package CSD_REFURBISH_IRO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSD_REFURBISH_IRO_GRP" AUTHID CURRENT_USER AS
/* $Header: csdriros.pls 120.1 2008/03/14 01:05:29 takwong ship $ */

/*--------------------------------------------------------------------*/
/* PROCEDURE Name : Get_PartySiteID                                   */
/* 	 x_return_status       	  Standard OUT param                    */
/*    x_msg_data                Standard OUT param                    */
/*    x_msg_count               Standard OUT param                    */
/*    p_site_use_type       	  Site Use Type Like To_Ship or To_Bill */
/*	 p_cust_site_use_id    	  Customer Site USe Id value            */
/* 	 x_party_site_use_id   	  Party Site Use Id OUT value           */
/* Description  : Takes Customer site use Id and site use type        */
/*                variables as input and returns corresponding        */
/*                party site use id , party Id and party site use id  */
/*--------------------------------------------------------------------*/
PROCEDURE Get_PartySiteId
  	(
 	 x_return_status      Out  NOCOPY   Varchar2,
	 x_msg_Data		  Out  NoCopy   Varchar2 ,
      x_msg_Count          Out  NoCopy   Number,
      p_site_use_type      In            Varchar2,
 	 p_cust_site_use_id   In            Number ,
      x_party_id           OUT  NOCOPY   Number,
      x_party_site_id      OUT  NOCOPY   Number,
      x_party_site_use_id  Out  NOCOPY   Number ) ;





/*-----------------------------------------------------------------------------------------*/
/*-- Create_InternalRO Procedure takes 4 input parameters p_Internal_SO_Header_Id_In,      */
/*-- p_Req_Header_Id_In,p_Internal_SO_Header_Id_Out, p_Req_Header_Id_Out and creates one   */
/*-- serive request and returns service request in x_Service_Request_Number out parameter. */
/*                                                                                         */
/*-- If procedure is not processed successfully then it returns error code and             */
/*-- message. In case procedure returns errors all database transactions are rolled        */
/*-- back. If item on internal sales order In is non serialized then one repair order      */
/*-- is created under above service request. If item is serialized then number of          */
/*-- repair orders will be as many as ordered quantity on internal sales order in.         */
/*-- THis procedure creates two product trxn lines for each repair order, one product      */
/*-- trxn line for internal SO Move In and another for internal SO Move out.               */
/*-- p_Internal_SO_Header_Id_In, p_Req_Header_Id_In,p_Internal_SO_Header_Id_Out,           */
/*-- p_Req_Header_Id_Out are required parameters.                                          */
/*-- Internal RO are always created under new SR.                                          */
/*-----------------------------------------------------------------------------------------*/
/*  Procedure Name : Create_InternalRO                                                     */
/*  P_api_version			     Standard In  param                                      */
/*  P_init_msg_list			     Standard In  param                                      */
/*  P_commit			          Standard In  param                                      */
/*  P_validation_level		     Standard In  param                                      */
/*  x_return_status	               Standard Out param                                      */
/*  x_msg_count	               Standard Out param                                      */
/*  x_msg_data	                    Standard Out param                                      */
/*  P_req_header_id_in		     Requisition Header Id for IO1 (Required)                */
/*  P_internal_SO_header_id_in	Internal SO header Id for IO1 (Required)                */
/*  P_req_header_id_out		     Requisition Header Id for IO2 (Required)                */
/*  P_internal_SO_header_id_out    Internal SO header Id for IO2 (Required)                */
/*  x_service_request_number	     Service Request Number OUT variable                     */
/*-----------------------------------------------------------------------------------------*/


 Procedure Create_InternalRO(
    P_api_version                In         Number,
    P_init_msg_list              In         Varchar2,
    P_commit                     In         Varchar2,
    P_validation_level           In         Number,
    x_return_status              Out NOCOPY Varchar2,
    x_msg_count	             Out NOCOPY Number,
    x_msg_data	                  Out NOCOPY Varchar2,
    P_req_header_id_in           In         Number,
    P_ISO_header_id_in           In         Number,
    P_req_header_id_out		   In         Number,
    P_ISO_header_id_out          In         Number,
    x_service_request_number     Out NOCOPY Varchar2,
    P_need_by_date               In         DATE := FND_API.G_MISS_DATE );  --Enhancement:3391950


End CSD_Refurbish_IRO_GRP ;

/
