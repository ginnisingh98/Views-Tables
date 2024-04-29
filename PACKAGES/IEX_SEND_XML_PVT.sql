--------------------------------------------------------
--  DDL for Package IEX_SEND_XML_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IEX_SEND_XML_PVT" AUTHID CURRENT_USER as
/* $Header: iexvxmls.pls 120.0.12010000.4 2009/12/29 13:07:09 pnaveenk ship $ */
-- Start of Comments
-- Package name     : IEX_SEND_XML_PVT
-- Purpose          : Generate XML Data and Delivery by XML Publisher
-- NOTE             :
-- History          :
--     11/08/2004 CLCHANG  Created.
-- End of Comments

TYPE bind_cnt_tbl is table of NUMBER index by binary_integer;


G_MISS_VARCHAR_TBL JTF_FM_REQUEST_GRP.G_VARCHAR_TBL_TYPE;


-- *************************
--   Validation Procedures
-- *************************



-- **************************
-- **************************

--   API Name:  Send_COPY

PROCEDURE Send_COPY(
    p_Api_Version_Number     IN  NUMBER,
    p_Init_Msg_List          IN  VARCHAR2   ,
    p_Commit                 IN  VARCHAR2   ,
    p_resend                 IN  VARCHAR2 DEFAULT NULL,
    p_request_id             IN  NUMBER DEFAULT NULL,
    p_User_id                IN  NUMBER,
    p_party_id               IN  NUMBER,
    p_subject                IN  VARCHAR2 ,
    p_bind_tbl      		     IN  IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL,
    p_template_id            IN  NUMBER,
    p_resource_id            IN  NUMBER,
    p_query_id               IN  NUMBER,
    p_method                 IN  VARCHAR2,
    p_dest                   IN  VARCHAR2,
    p_level                  IN  VARCHAR2,
    p_source_id              IN  NUMBER,
    p_object_type            IN  VARCHAR2,
    p_object_id              IN  NUMBER,
    p_dunning_mode           IN  VARCHAR2,  -- added by gnramasa for bug 8489610 14-May-09
    p_parent_request_id      IN NUMBER DEFAULT NULL,
    p_org_id                 in number default null, -- added for bug 9151851
    X_Request_ID             OUT NOCOPY NUMBER,
    X_Return_Status          OUT NOCOPY VARCHAR2,
    X_Msg_Count              OUT NOCOPY NUMBER,
    X_Msg_Data               OUT NOCOPY VARCHAR2
    );

/*
   Overview: This function is to get the xml data from a query which is defined by the dunning letter template.
   Parameter: p_party_id : party_id
   Return:  clob contains the result of the query
   creation date: 08/25/2004
   author:  ctlee
   Note: test only
 */
procedure GetXmlData
(
    p_party_id       IN  number
  , p_resource_id    IN  number
  , p_bind_tbl       IN  IEX_DUNNING_PVT.FULFILLMENT_BIND_TBL
  , p_query_id       IN  number
  , x_return_status           OUT NOCOPY VARCHAR2
  , x_msg_count               OUT NOCOPY NUMBER
  , x_msg_data                OUT NOCOPY VARCHAR2
  , x_xml            OUT NOCOPY clob
) ;


/*
   Overview: This function is to retrieve the existing xml data from
             iex_xml_request_histories table.
*/
procedure RetrieveXmlData
(
    p_request_id              IN  number
  , x_return_status           OUT NOCOPY VARCHAR2
  , x_msg_count               OUT NOCOPY NUMBER
  , x_msg_data                OUT NOCOPY VARCHAR2
  , x_xml                     OUT NOCOPY clob
) ;


/*
   Overview: This function is to get the current setup in IEX ADMIN/SETUP
             (iex_app_preferences_vl) for 'COLLECTIONS DELIVERY METHOD'.
*/
function getCurrDeliveryMethod
return varchar2;



Procedure WriteLog      (  p_msg                     IN VARCHAR2 );



End IEX_SEND_XML_PVT;

/
