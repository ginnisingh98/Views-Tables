--------------------------------------------------------
--  DDL for Package CLN_CH_COLLABORATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_CH_COLLABORATION_PKG" AUTHID CURRENT_USER AS
/* $Header: ECXCHCHS.pls 120.1 2005/08/26 06:55:20 nparihar noship $ */
/*#
* This package is called by both inbound and outbound operations from the application whenever a new collaboration has to be started. Also, the details of any existing collaboration can also be retrieved/updated by calling this package.
* @rep:scope private
* @rep:product CLN
* @rep:displayname CLN API for Collaboration History core functionality
* @rep:category BUSINESS_ENTITY  CLN_TRADING_PARTNER_COLL
* @rep:category BUSINESS_ENTITY  CLN_TRADING_PARTNER_COLL_EVENT
* @rep:compatibility  S
* @rep:lifecycle  active
*/
--  Package
--      CLN_CH_COLLABORATION_PKG
--
--  Purpose
--      Spec of package CLN_CH_COLLABORATION_PKG. This package
--      is called by both inbound and outbound operations from the application
--      when ever a new collaboration has to be started.Also,the details of any
--      existing collaboration can also be retrieved/updated by calling this package.
--
--  History
--      Mar-26-2002     Rahul Krishan         Created
--      Apr-12-2002     Rahul Krishan         Updated

   g_xmlg_oag_application_ref_id VARCHAR2(255); -- Global variable which is set by CLNCHETB with the default ref id
                                                -- CLNCHETB obtains it by processing ECX_EVENT_MESSAGE attribute


-- Name
--    GET_CONTROL_AREA_REFID
-- Purpose
--    This procedure is called to retrieve application reference ID based on
--    XML message ID from control area of the payload
-- Arguments
--    XML Gateway Message ID
-- Notes
--    Uses a DOM Parser to parse the document and retrieve the application reference ID
/*#
* This procedure is called to retrieve application reference ID based on XML message ID from control area of the payload.
* @param p_msgId value
* @param p_collaboration_standard value
* @param x_app_ref_id value
* @param p_app_id value
* @param p_coll_type value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Gets Control Area Refid
*/
    PROCEDURE GET_CONTROL_AREA_REFID(
      p_msgId                   IN  RAW,
      p_collaboration_standard  IN VARCHAR2,
      x_app_ref_id              IN OUT NOCOPY VARCHAR2,
      p_app_id                  IN  VARCHAR2,
      p_coll_type               IN  VARCHAR2);

-- Name
--    GET_DATA_AREA_REFID
-- Purpose
--    This procedure is called to retrieve application reference ID based on
--    XML message ID from data area of the payload
-- Arguments
--    XML Gateway Message ID
-- Notes
--    Uses a DOM Parser to parse the document and retrieve the application reference ID
/*#
* This procedure is called to retrieve application reference ID based on XML message ID from data area of the payload.
* @param p_msgId value
* @param p_collaboration_standard value
* @param x_app_ref_id value
* @param p_app_id value
* @param p_coll_type value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Gets Data Area Refid
*/

   PROCEDURE GET_DATA_AREA_REFID(
      p_msgId                   IN  RAW,
      p_collaboration_standard  IN VARCHAR2,
      x_app_ref_id              IN OUT NOCOPY VARCHAR2,
      p_app_id                  IN  VARCHAR2,
      p_coll_type               IN  VARCHAR2);

  -- Name
  --   CREATE_COLLABORATION
  -- Purpose
  --   This is the public procedure which starts a new Collaboration
  --   and adds the initial details corresponding to it in both the CLN_COLL_HIST_HDR
  --   and CLN_COLL_HIST_DTL Tables.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure starts a new Collaboration and adds the initial details corresponding to it in both the CLN_COLL_HIST_HDR and CLN_COLL_HIST_DTL Tables.
* @param  x_return_status value
* @param  x_msg_data value
* @param  p_app_id value
* @param  p_ref_id value
* @param  p_org_id value
* @param  p_rel_no value
* @param  p_doc_no value
* @param  p_doc_rev_no value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_xmlg_document_id value
* @param  p_partner_doc_no value
* @param  p_coll_type value
* @param  p_tr_partner_type value
* @param  p_tr_partner_id value
* @param  p_tr_partner_site value
* @param  p_resend_flag value
* @param  p_resend_count value
* @param p_doc_owner value
* @param  p_init_date value
* @param p_doc_creation_date value
* @param p_doc_revision_date value
* @param p_doc_type value
* @param p_doc_dir value
* @param p_coll_pt value
* @param p_xmlg_msg_id value
* @param p_unique1 value
* @param p_unique2 value
* @param p_unique3 value
* @param p_unique4 value
* @param p_unique5 value
* @param p_sender_component value
* @param p_rosettaNet_check_required value
* @param x_coll_id  value
* @param p_xmlg_internal_control_number value
* @param p_xmlg_int_transaction_type value
* @param p_xmlg_int_transaction_subtype value
* @param p_collaboration_standard value
* @param p_msg_text value
* @param p_xml_event_key value
* @param p_attribute1 value
* @param p_attribute2 value
* @param p_attribute3 value
* @param p_attribute4 value
* @param p_attribute5 value
* @param p_attribute6 value
* @param p_attribute7 value
* @param p_attribute8 value
* @param p_attribute9 value
* @param p_attribute10 value
* @param p_attribute11 value
* @param p_attribute12 value
* @param p_attribute13 value
* @param p_attribute14 value
* @param p_attribute15 value
* @param p_dattribute1 value
* @param p_dattribute2 value
* @param p_dattribute3 value
* @param p_dattribute4 value
* @param p_dattribute5 value
* @param p_owner_role value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Creates a Collaboration
*/
    PROCEDURE CREATE_COLLABORATION(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_app_id                               IN  VARCHAR2 DEFAULT NULL,
         p_ref_id                               IN  VARCHAR2 DEFAULT NULL,
         p_org_id                               IN  NUMBER   DEFAULT NULL,
         p_rel_no                               IN  VARCHAR2 DEFAULT NULL,
         p_doc_no                               IN  VARCHAR2 DEFAULT NULL,
         p_doc_rev_no                           IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_transaction_type                IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_transaction_subtype             IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_document_id                     IN  VARCHAR2 DEFAULT NULL,
         p_partner_doc_no                       IN  VARCHAR2 DEFAULT NULL,
         p_coll_type                            IN  VARCHAR2 DEFAULT NULL,
         p_tr_partner_type                      IN  VARCHAR2 DEFAULT NULL,
         p_tr_partner_id                        IN  VARCHAR2 DEFAULT NULL,
         p_tr_partner_site                      IN  VARCHAR2 DEFAULT NULL,
         p_resend_flag                          IN  VARCHAR2 DEFAULT NULL,
         p_resend_count                         IN  NUMBER DEFAULT NULL,
         p_doc_owner                            IN  VARCHAR2 DEFAULT NULL,
         p_init_date                            IN  DATE DEFAULT SYSDATE,
         p_doc_creation_date                    IN  DATE DEFAULT NULL,
         p_doc_revision_date                    IN  DATE DEFAULT NULL,
         p_doc_type                             IN  VARCHAR2 DEFAULT NULL,
         p_doc_dir                              IN  VARCHAR2 DEFAULT NULL,
         p_coll_pt                              IN  VARCHAR2 DEFAULT 'APPS',
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_unique1                              IN  VARCHAR2 DEFAULT NULL,
         p_unique2                              IN  VARCHAR2 DEFAULT NULL,
         p_unique3                              IN  VARCHAR2 DEFAULT NULL,
         p_unique4                              IN  VARCHAR2 DEFAULT NULL,
         p_unique5                              IN  VARCHAR2 DEFAULT NULL,
         p_sender_component                     IN  VARCHAR2 DEFAULT NULL,
         p_rosettanet_check_required            IN  BOOLEAN  DEFAULT TRUE,
         x_coll_id                              OUT NOCOPY NUMBER,
         p_xmlg_internal_control_number         IN  NUMBER DEFAULT NULL,
         p_xmlg_int_transaction_type            IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2 DEFAULT NULL,
         p_msg_text                             IN  VARCHAR2 DEFAULT NULL,
         p_xml_event_key                        IN  VARCHAR2 DEFAULT NULL,
         p_collaboration_standard               IN  VARCHAR2 DEFAULT NULL,
         p_attribute1                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute2                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute3                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute4                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute5                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute6                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute7                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute8                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute9                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute10                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute11                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute12                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute13                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute14                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute15                          IN  VARCHAR2 DEFAULT NULL,
         p_dattribute1                          IN  DATE     DEFAULT NULL,
         p_dattribute2                          IN  DATE     DEFAULT NULL,
         p_dattribute3                          IN  DATE     DEFAULT NULL,
         p_dattribute4                          IN  DATE     DEFAULT NULL,
         p_dattribute5                          IN  DATE     DEFAULT NULL,
         p_owner_role                           IN  VARCHAR2 DEFAULT NULL  );



  -- Name
  --   UPDATE_COLLABORATION
  -- Purpose
  --   This is the public procedure which is called at subsequent stages after creation,
  --   to update collaboration with the progress.It creates a new row in the CLN_COLL_HIST_DTL
  --   table and also modifies the CLN_COLL_HIST_HDR if the need may be.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure is called at subsequent stages after creation to update collaboration with the progress. It creates a new row in the CLN_COLL_HIST_DTL table and also modifies the CLN_COLL_HIST_HDR if the need may be.
* @param  x_return_status value
* @param  x_msg_data value
* @param  p_coll_id value
* @param  p_app_id value
* @param  p_ref_id value
* @param  p_rel_no value
* @param  p_doc_no value
* @param  p_doc_rev_no value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_xmlg_document_id value
* @param  p_resend_flag value
* @param  p_resend_count value
* @param  p_disposition value
* @param  p_coll_status value
* @param p_doc_type value
* @param p_doc_dir value
* @param p_coll_pt value
* @param  p_org_ref value
* @param  p_doc_status value
* @param  p_notification_id value
* @param  p_msg_text value
* @param  p_bsr_verb value
* @param  p_bsr_noun value
* @param  p_bsr_rev value
* @param  p_sdr_logical_id value
* @param  p_sdr_component value
* @param  p_sdr_task value
* @param  p_sdr_refid value
* @param  p_sdr_confirmation value
* @param  p_sdr_language value
* @param  p_sdr_codepage value
* @param  p_sdr_authid value
* @param  p_sdr_datetime_qualifier value
* @param  p_sdr_datetime value
* @param  p_sdr_timezone value
* @param  p_attr1 value
* @param  p_attr2 value
* @param  p_attr3 value
* @param  p_attr4 value
* @param  p_attr5 value
* @param  p_attr6 value
* @param  p_attr7 value
* @param  p_attr8 value
* @param  p_attr9 value
* @param  p_attr10 value
* @param  p_attr11 value
* @param  p_attr12 value
* @param  p_attr13 value
* @param  p_attr14 value
* @param  p_attr15 value
* @param p_xmlg_msg_id value
* @param p_unique1 value
* @param p_unique2 value
* @param p_unique3 value
* @param p_unique4 value
* @param p_unique5 value
* @param  p_tr_partner_type value
* @param  p_tr_partner_id value
* @param  p_tr_partner_site value
* @param p_sender_component value
* @param p_RosettaNet_check_required value
* @param x_dtl_coll_id  value
* @param p_xmlg_internal_control_number value
* @param  p_partner_doc_no value
* @param  p_org_id value
* @param p_doc_creation_date value
* @param p_doc_revision_date value
* @param p_doc_owner value
* @param p_xmlg_int_transaction_type value
* @param p_xmlg_int_transaction_subtype value
* @param  p_xml_event_key value
* @param p_collaboration_standard value
* @param p_attribute1 value
* @param p_attribute2 value
* @param p_attribute3 value
* @param p_attribute4 value
* @param p_attribute5 value
* @param p_attribute6 value
* @param p_attribute7 value
* @param p_attribute8 value
* @param p_attribute9 value
* @param p_attribute10 value
* @param p_attribute11 value
* @param p_attribute12 value
* @param p_attribute13 value
* @param p_attribute14 value
* @param p_attribute15 value
* @param p_dattribute1 value
* @param p_dattribute2 value
* @param p_dattribute3 value
* @param p_dattribute4 value
* @param p_dattribute5 value
* @param p_owner_role value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Updates a Collaboration
*/
    PROCEDURE UPDATE_COLLABORATION(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_coll_id                              IN  NUMBER DEFAULT NULL,
         p_app_id                               IN  VARCHAR2 DEFAULT NULL,
         p_ref_id                               IN  VARCHAR2 DEFAULT NULL,
         p_rel_no                               IN  VARCHAR2 DEFAULT NULL,
         p_doc_no                               IN  VARCHAR2 DEFAULT NULL,
         p_doc_rev_no                           IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_transaction_type                IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_transaction_subtype             IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_document_id                     IN  VARCHAR2 DEFAULT NULL,
         p_resend_flag                          IN  VARCHAR2 DEFAULT NULL,
         p_resend_count                         IN  NUMBER DEFAULT NULL,
         p_disposition                          IN  VARCHAR2 DEFAULT NULL,
         p_coll_status                          IN  VARCHAR2 DEFAULT NULL,
         p_doc_type                             IN  VARCHAR2 DEFAULT NULL,
         p_doc_dir                              IN  VARCHAR2 DEFAULT NULL,
         p_coll_pt                              IN  VARCHAR2 DEFAULT 'APPS',
         p_org_ref                              IN  VARCHAR2 DEFAULT NULL,
         p_doc_status                           IN  VARCHAR2 DEFAULT 'SUCCESS',
         p_notification_id                      IN  VARCHAR2 DEFAULT NULL,
         p_msg_text                             IN  VARCHAR2,
         p_bsr_verb                             IN  VARCHAR2 DEFAULT NULL,
         p_bsr_noun                             IN  VARCHAR2 DEFAULT NULL,
         p_bsr_rev                              IN  VARCHAR2 DEFAULT NULL,
         p_sdr_logical_id                       IN  VARCHAR2 DEFAULT NULL,
         p_sdr_component                        IN  VARCHAR2 DEFAULT NULL,
         p_sdr_task                             IN  VARCHAR2 DEFAULT NULL,
         p_sdr_refid                            IN  VARCHAR2 DEFAULT NULL,
         p_sdr_confirmation                     IN  VARCHAR2 DEFAULT NULL,
         p_sdr_language                         IN  VARCHAR2 DEFAULT NULL,
         p_sdr_codepage                         IN  VARCHAR2 DEFAULT NULL,
         p_sdr_authid                           IN  VARCHAR2 DEFAULT NULL,
         p_sdr_datetime_qualifier               IN  VARCHAR2 DEFAULT NULL,
         p_sdr_datetime                         IN  VARCHAR2 DEFAULT NULL,
         p_sdr_timezone                         IN  VARCHAR2 DEFAULT NULL,
         p_attr1                                IN  VARCHAR2 DEFAULT NULL,
         p_attr2                                IN  VARCHAR2 DEFAULT NULL,
         p_attr3                                IN  VARCHAR2 DEFAULT NULL,
         p_attr4                                IN  VARCHAR2 DEFAULT NULL,
         p_attr5                                IN  VARCHAR2 DEFAULT NULL,
         p_attr6                                IN  VARCHAR2 DEFAULT NULL,
         p_attr7                                IN  VARCHAR2 DEFAULT NULL,
         p_attr8                                IN  VARCHAR2 DEFAULT NULL,
         p_attr9                                IN  VARCHAR2 DEFAULT NULL,
         p_attr10                               IN  VARCHAR2 DEFAULT NULL,
         p_attr11                               IN  VARCHAR2 DEFAULT NULL,
         p_attr12                               IN  VARCHAR2 DEFAULT NULL,
         p_attr13                               IN  VARCHAR2 DEFAULT NULL,
         p_attr14                               IN  VARCHAR2 DEFAULT NULL,
         p_attr15                               IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_unique1                              IN  VARCHAR2 DEFAULT NULL,
         p_unique2                              IN  VARCHAR2 DEFAULT NULL,
         p_unique3                              IN  VARCHAR2 DEFAULT NULL,
         p_unique4                              IN  VARCHAR2 DEFAULT NULL,
         p_unique5                              IN  VARCHAR2 DEFAULT NULL,
         p_tr_partner_type                      IN  VARCHAR2 DEFAULT NULL,
         p_tr_partner_id                        IN  VARCHAR2 DEFAULT NULL,
         p_tr_partner_site                      IN  VARCHAR2 DEFAULT NULL,
         p_sender_component                     IN  VARCHAR2 DEFAULT NULL,
         p_rosettanet_check_required            IN  BOOLEAN DEFAULT TRUE,
         x_dtl_coll_id                          OUT NOCOPY NUMBER,
         p_xmlg_internal_control_number         IN  NUMBER DEFAULT NULL,
         p_partner_doc_no                       IN  VARCHAR2 DEFAULT NULL,
         p_org_id                               IN  NUMBER DEFAULT NULL,
         p_doc_creation_date                    IN  DATE DEFAULT NULL,
         p_doc_revision_date                    IN  DATE DEFAULT NULL,
         p_doc_owner                            IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_int_transaction_type            IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2 DEFAULT NULL,
         p_xml_event_key                       IN  VARCHAR2 DEFAULT NULL,
         p_collaboration_standard               IN  VARCHAR2 DEFAULT NULL,
         p_attribute1                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute2                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute3                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute4                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute5                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute6                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute7                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute8                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute9                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute10                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute11                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute12                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute13                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute14                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute15                          IN  VARCHAR2 DEFAULT NULL,
         p_dattribute1                          IN  DATE     DEFAULT NULL,
         p_dattribute2                          IN  DATE     DEFAULT NULL,
         p_dattribute3                          IN  DATE     DEFAULT NULL,
         p_dattribute4                          IN  DATE     DEFAULT NULL,
         p_dattribute5                          IN  DATE     DEFAULT NULL,
         p_owner_role                           IN  VARCHAR2 DEFAULT NULL  );



  -- Name
  --   FIND_COLLABORATION_STATUS
  -- Purpose
  --   This is the public procedure which may be called by the user to
  --   know the status of any Collaboration.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure may be called by the user to know the status of any Collaboration.
* @param  x_return_status value
* @param  x_msg_data value
* @param  p_coll_id value
* @param  p_app_id value
* @param  p_ref_id value
* @param  p_rel_no value
* @param  p_doc_no value
* @param  p_doc_rev_no value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_xmlg_document_id value
* @param p_unique1 value
* @param p_unique2 value
* @param p_unique3 value
* @param p_unique4 value
* @param p_unique5 value
* @param p_doc_direction value
* @param p_xmlg_msg_id  value
* @param p_xmlg_internal_control_number value
* @param x_coll_status value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Finds Collaboration Status
*/
    PROCEDURE FIND_COLLABORATION_STATUS(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_coll_id                      IN  NUMBER,
         p_app_id                       IN  VARCHAR2,
         p_ref_id                       IN  VARCHAR2,
         p_rel_no                       IN  VARCHAR2,
         p_doc_no                       IN  VARCHAR2,
         p_doc_rev_no                   IN  VARCHAR2,
         p_xmlg_transaction_type        IN  VARCHAR2,
         p_xmlg_transaction_subtype     IN  VARCHAR2,
         p_xmlg_document_id             IN  VARCHAR2,
         x_coll_status                  OUT NOCOPY VARCHAR2,
         p_unique1                      IN  VARCHAR2,
         p_unique2                      IN  VARCHAR2,
         p_unique3                      IN  VARCHAR2,
         p_unique4                      IN  VARCHAR2,
         p_unique5                      IN  VARCHAR2,
         p_doc_direction                IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_msg_id                  IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_internal_control_number IN  NUMBER DEFAULT NULL );



  -- Name
  --   RETRIEVE_COLLABORATION_DETAILS
  -- Purpose
  --   This is the public procedure which may be called to retrieve the details of any
  --   collaboration.
  -- Arguments
  --
  -- Notes
  --   No specific notes.

/*#
* This procedure may be called to retrieve  the details of any collaboration.
* @param  x_return_status value
* @param  x_msg_data value
* @param  p_dtl_coll_id value
* @param  p_coll_id value
* @param  x_app_id value
* @param  x_ref_id value
* @param  x_rel_no value
* @param  x_doc_no value
* @param  x_doc_rev_no value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_xmlg_document_id value
* @param  x_resend_flag value
* @param  x_resend_count value
* @param  x_disposition value
* @param  x_coll_status value
* @param  x_org_id value
* @param  x_tr_partner_id value
* @param x_doc_owner value
* @param  x_init_date value
* @param x_doc_creation_date value
* @param x_doc_revision_date value
* @param x_doc_type value
* @param x_doc_dir value
* @param x_coll_pt value
* @param  x_org_ref value
* @param  x_doc_status value
* @param  x_notification_id value
* @param  x_msg_text value
* @param  x_bsr_verb value
* @param  x_bsr_noun value
* @param  x_bsr_rev value
* @param  x_sdr_logical_id value
* @param  x_sdr_component value
* @param  x_sdr_task value
* @param  x_sdr_refid value
* @param  x_sdr_confirmation value
* @param  x_sdr_language value
* @param  x_sdr_codepage value
* @param  x_sdr_authid value
* @param  x_sdr_datetime_qualifier value
* @param  x_sdr_datetime value
* @param  x_sdr_timezone value
* @param  x_attr1 value
* @param  x_attr2 value
* @param  x_attr3 value
* @param  x_attr4 value
* @param  x_attr5 value
* @param  x_attr6 value
* @param  x_attr7 value
* @param  x_attr8 value
* @param  x_attr9 value
* @param  x_attr10 value
* @param  x_attr11 value
* @param  x_attr12 value
* @param  x_attr13 value
* @param  x_attr14 value
* @param  x_attr15 value
* @param x_xmlg_msg_id value
* @param p_unique1 value
* @param p_unique2 value
* @param p_unique3 value
* @param p_unique4 value
* @param p_unique5 value
* @param p_xmlg_internal_control_number value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Retrives Collaboration Details
*/
    PROCEDURE RETRIEVE_COLLABORATION_DETAILS(
         x_return_status                OUT NOCOPY VARCHAR2,
         x_msg_data                     OUT NOCOPY VARCHAR2,
         p_dtl_coll_id                  IN  NUMBER,
         p_coll_id                      IN  NUMBER,
         x_app_id                       IN OUT NOCOPY VARCHAR2,
         x_ref_id                       IN OUT NOCOPY VARCHAR2,
         x_rel_no                       IN OUT NOCOPY VARCHAR2,
         x_doc_no                       IN OUT NOCOPY VARCHAR2,
         x_doc_rev_no                   IN OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_type        IN OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_subtype     IN OUT NOCOPY VARCHAR2,
         p_xmlg_document_id             IN OUT NOCOPY VARCHAR2,
         x_resend_flag                  OUT NOCOPY  VARCHAR2,
         x_resend_count                 OUT NOCOPY  NUMBER,
         x_disposition                  OUT NOCOPY  VARCHAR2,
         x_coll_status                  OUT NOCOPY  VARCHAR2,
         x_org_id                       OUT NOCOPY  NUMBER,
         x_tr_partner_id                OUT NOCOPY  VARCHAR2,
         x_doc_owner                    OUT NOCOPY  VARCHAR2,
         x_init_date                    OUT NOCOPY  DATE,
         x_doc_creation_date            OUT NOCOPY  DATE,
         x_doc_revision_date            OUT NOCOPY  DATE,
         x_doc_type                     IN OUT NOCOPY  VARCHAR2,
         x_doc_dir                      IN OUT NOCOPY  VARCHAR2,
         x_coll_pt                      IN OUT NOCOPY  VARCHAR2,
         x_org_ref                      OUT NOCOPY  VARCHAR2,
         x_doc_status                   OUT NOCOPY  VARCHAR2,
         x_notification_id              OUT NOCOPY  VARCHAR2,
         x_msg_text                     OUT NOCOPY  VARCHAR2,
         x_bsr_verb                     OUT NOCOPY  VARCHAR2,
         x_bsr_noun                     OUT NOCOPY  VARCHAR2,
         x_bsr_rev                      OUT NOCOPY  VARCHAR2,
         x_sdr_logical_id               OUT NOCOPY  VARCHAR2,
         x_sdr_component                OUT NOCOPY  VARCHAR2,
         x_sdr_task                     OUT NOCOPY  VARCHAR2,
         x_sdr_refid                    OUT NOCOPY  VARCHAR2,
         x_sdr_confirmation             OUT NOCOPY  VARCHAR2,
         x_sdr_language                 OUT NOCOPY  VARCHAR2,
         x_sdr_codepage                 OUT NOCOPY  VARCHAR2,
         x_sdr_authid                   OUT NOCOPY  VARCHAR2,
         x_sdr_datetime_qualifier       OUT NOCOPY  VARCHAR2,
         x_sdr_datetime                 OUT NOCOPY  VARCHAR2,
         x_sdr_timezone                 OUT NOCOPY  VARCHAR2,
         x_attr1                        OUT NOCOPY  VARCHAR2,
         x_attr2                        OUT NOCOPY  VARCHAR2,
         x_attr3                        OUT NOCOPY  VARCHAR2,
         x_attr4                        OUT NOCOPY  VARCHAR2,
         x_attr5                        OUT NOCOPY  VARCHAR2,
         x_attr6                        OUT NOCOPY  VARCHAR2,
         x_attr7                        OUT NOCOPY  VARCHAR2,
         x_attr8                        OUT NOCOPY  VARCHAR2,
         x_attr9                        OUT NOCOPY  VARCHAR2,
         x_attr10                       OUT NOCOPY  VARCHAR2,
         x_attr11                       OUT NOCOPY  VARCHAR2,
         x_attr12                       OUT NOCOPY  VARCHAR2,
         x_attr13                       OUT NOCOPY  VARCHAR2,
         x_attr14                       OUT NOCOPY  VARCHAR2,
         x_attr15                       OUT NOCOPY  VARCHAR2,
         x_xmlg_msg_id                  IN OUT NOCOPY  VARCHAR2,
         p_unique1                      IN  VARCHAR2,
         p_unique2                      IN  VARCHAR2,
         p_unique3                      IN  VARCHAR2,
         p_unique4                      IN  VARCHAR2,
         p_unique5                      IN  VARCHAR2,
         p_xmlg_internal_control_number IN OUT NOCOPY NUMBER );



  -- Name
  --   ADD_COLLABORATION_MESSAGES
  -- Purpose
  --   This is the public procedure which may be called by user for adding
  --   detail messages related with any Collaboration.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure may be called by user for adding detailed messages related with any Collaboration.

* @param  x_return_status value
* @param  x_msg_data value
* @param  p_dtl_coll_id value
* @param  p_ref1 value
* @param  p_ref2 value
* @param  p_ref3 value
* @param  p_ref4 value
* @param  p_ref5 value
* @param  p_dtl_msg value
* @param  p_coll_id value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_xmlg_document_id value
* @param  p_doc_type value
* @param  p_doc_direction value
* @param  p_coll_point value
* @param  p_xmlg_internal_control_number value
* @param  p_xmlg_int_transaction_type value
* @param  p_xmlg_int_transaction_subtype value
* @param  p_xmlg_msg_id value
* @param  p_app_id value
* @param  p_ref_id value
* @param  p_unique1 value
* @param  p_unique2 value
* @param  p_unique3 value
* @param  p_unique4 value
* @param  p_unique5 value
* @param p_xml_event_key value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Adds Collaboration Messages
*/
    PROCEDURE ADD_COLLABORATION_MESSAGES(
         x_return_status                     OUT NOCOPY VARCHAR2,
         x_msg_data                          OUT NOCOPY VARCHAR2,
         p_dtl_coll_id                       IN  NUMBER,
         p_ref1                              IN  VARCHAR2 DEFAULT NULL,
         p_ref2                              IN  VARCHAR2 DEFAULT NULL,
         p_ref3                              IN  VARCHAR2 DEFAULT NULL,
         p_ref4                              IN  VARCHAR2 DEFAULT NULL,
         p_ref5                              IN  VARCHAR2 DEFAULT NULL,
         p_dtl_msg                           IN  VARCHAR2,
         p_coll_id                           IN  NUMBER DEFAULT NULL,
         p_xmlg_transaction_type             IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_transaction_subtype          IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_document_id                  IN  VARCHAR2 DEFAULT NULL,
         p_doc_type                          IN  VARCHAR2 DEFAULT NULL,
         p_doc_direction                     IN  VARCHAR2 DEFAULT NULL,
         p_coll_point                        IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_internal_control_number      IN  NUMBER DEFAULT NULL,
         p_xmlg_int_transaction_type         IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_int_transaction_subtype      IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_msg_id                       IN  VARCHAR2 DEFAULT NULL,
         p_xml_event_key                     IN  VARCHAR2 DEFAULT NULL,
         p_app_id                            IN  VARCHAR2 DEFAULT NULL,
         p_ref_id                            IN  VARCHAR2 DEFAULT NULL,
         p_unique1                           IN  VARCHAR2 DEFAULT NULL,
         p_unique2                           IN  VARCHAR2 DEFAULT NULL,
         p_unique3                           IN  VARCHAR2 DEFAULT NULL,
         p_unique4                           IN  VARCHAR2 DEFAULT NULL,
         p_unique5                           IN  VARCHAR2 DEFAULT NULL );



  -- Name
  --   IS_UPDATE_REQUIRED
  -- Purpose
  --   This is the public procedure which checks for the protocol used
  --   based on few parameters passed in and accordingly,collaboration is updated.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure checks for the protocol used based on few parameters passed in and accordingly, collaboration is updated.
* @param  x_return_status value
* @param  x_msg_data value
* @param  p_doc_dir value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param p_tr_partner_type value
* @param  p_tr_partner_id value
* @param  p_tr_partner_site value
* @param  p_sender_component value
* @param  x_update_reqd value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Checks if Update is required
*/
    PROCEDURE IS_UPDATE_REQUIRED(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_doc_dir                              IN  VARCHAR2,
         p_xmlg_transaction_type                IN  VARCHAR2,
         p_xmlg_transaction_subtype             IN  VARCHAR2,
         p_tr_partner_type                      IN  VARCHAR2,
         p_tr_partner_id                        IN  VARCHAR2,
         p_tr_partner_site                      IN  VARCHAR2,
         p_sender_component                     IN  VARCHAR2,
         x_update_reqd                          OUT NOCOPY BOOLEAN);




 -- Name
  --   FIND_COLLABORATION_DETAIL_ID
  -- Purpose
  --   This is the public procedure which may be called by the user to
  --   query the detail collaboration id.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure may be used to get the latest collaboration detail id for a particular collaboration id or other parameters.
* @param  x_return_status value
* @param  x_msg_data value
* @param  p_coll_id value
* @param  p_app_id value
* @param  p_ref_id value
* @param  p_rel_no value
* @param  p_doc_no value
* @param  p_doc_rev_no value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_xmlg_document_id value
* @param  p_unique1 value
* @param  p_unique2 value
* @param  p_unique3 value
* @param  p_unique4 value
* @param  p_unique5 value
* @param  p_doc_type value
* @param  p_doc_direction value
* @param  p_coll_point value
* @param x_dtl_coll_id value
* @param  p_xmlg_msg_id value
* @param  p_xmlg_internal_control_number value
* @param  p_xmlg_int_transaction_type value
* @param  p_xmlg_int_transaction_subtype value
* @param  p_xml_event_key value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Finds Collaboration Detail Id
*/
     PROCEDURE FIND_COLLABORATION_DETAIL_ID(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_coll_id                              IN  NUMBER,
         p_app_id                               IN  VARCHAR2 DEFAULT NULL,
         p_ref_id                               IN  VARCHAR2 DEFAULT NULL,
         p_rel_no                               IN  VARCHAR2 DEFAULT NULL,
         p_doc_no                               IN  VARCHAR2 DEFAULT NULL,
         p_doc_rev_no                           IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_transaction_type                IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_transaction_subtype             IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_document_id                     IN  VARCHAR2 DEFAULT NULL,
         p_unique1                              IN  VARCHAR2 DEFAULT NULL,
         p_unique2                              IN  VARCHAR2 DEFAULT NULL,
         p_unique3                              IN  VARCHAR2 DEFAULT NULL,
         p_unique4                              IN  VARCHAR2 DEFAULT NULL,
         p_unique5                              IN  VARCHAR2 DEFAULT NULL,
         p_doc_type                             IN  VARCHAR2 DEFAULT NULL,
         p_doc_direction                        IN  VARCHAR2 DEFAULT NULL,
         p_coll_point                           IN  VARCHAR2 DEFAULT NULL,
         x_dtl_coll_id                          OUT NOCOPY NUMBER,
         p_xmlg_msg_id                          IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_internal_control_number         IN  NUMBER DEFAULT NULL,
         p_xmlg_int_transaction_type            IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2 DEFAULT NULL,
         p_xml_event_key                       IN  VARCHAR2 DEFAULT NULL);




  -- Name
  --   GET_TRADING_PARTNER_DETAILS
  -- Purpose
  --   This is the public procedure which checks for the trading partner details from the
  --   xmlg tables based on the parameters passed.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure checks for the trading partner details from the xmlg tables based on the parameters passed.
* @param  x_return_status value
* @param  x_msg_data value
* @param  p_xmlg_internal_control_number value
* @param  p_xmlg_msg_id value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_xmlg_int_transaction_type value
* @param  p_xmlg_int_transaction_subtype value
* @param  p_xmlg_document_id value
* @param  p_doc_dir value
* @param  p_tr_partner_type value
* @param  p_tr_partner_id value
* @param  p_tr_partner_site value
* @param  p_sender_component value
* @param  p_xml_event_key value
* @param  p_collaboration_standard value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Gets Trading Patner Details
*/
     PROCEDURE GET_TRADING_PARTNER_DETAILS(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_xmlg_internal_control_number         IN OUT NOCOPY NUMBER,
         p_xmlg_msg_id                          IN OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_type                IN OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_subtype             IN OUT NOCOPY VARCHAR2,
         p_xmlg_int_transaction_type            IN OUT NOCOPY VARCHAR2,
         p_xmlg_int_transaction_subtype         IN OUT NOCOPY VARCHAR2,
         p_xmlg_document_id                     IN OUT NOCOPY VARCHAR2,
         p_doc_dir                              IN OUT NOCOPY VARCHAR2,
         p_tr_partner_type                      IN OUT NOCOPY VARCHAR2,
         p_tr_partner_id                        IN OUT NOCOPY VARCHAR2,
         p_tr_partner_site                      IN OUT NOCOPY VARCHAR2,
         p_sender_component                     IN OUT NOCOPY VARCHAR2,
         p_xml_event_key                       IN OUT NOCOPY VARCHAR2,
         p_collaboration_standard               IN OUT NOCOPY VARCHAR2);



  -- Name
  --   DEFAULT_XMLGTXN_MAPPING
  -- Purpose
  --   This is the public procedure which returns the application id for a given set of
  --   parameters passed while refering to teh CLN_CH_XMLGTXN_MAPPING.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure returns the application id for a given set of parameters passed while referring to the CLN_CH_XMLGTXN_MAPPING.
* @param  x_return_status value
* @param  x_msg_data value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_doc_dir value
* @param  p_app_id value
* @param  p_coll_type value
* @param  p_doc_type value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Internal XMLG transaction mapping call.
*/
     PROCEDURE DEFAULT_XMLGTXN_MAPPING(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_xmlg_transaction_type                IN  VARCHAR2,
         p_xmlg_transaction_subtype             IN  VARCHAR2,
         p_doc_dir                              IN  VARCHAR2,
         p_app_id                               IN OUT NOCOPY VARCHAR2 ,
         p_coll_type                            IN OUT NOCOPY VARCHAR2,
         p_doc_type                             IN OUT NOCOPY VARCHAR2 );


  -- Name
  --   DEFAULT_COLLABORATION_STATUS
  -- Purpose
  --   This procedure defaults collaboration status based on the rules defined in
  --   CLN_COLL_STATUS_MAPPING table.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure defaults collaboration status based on the rules defined in CLN_COLL_STATUS_MAPPING table.
* @param  x_return_status value
* @param  x_msg_data value
* @param  x_coll_status value
* @param  p_app_id value
* @param  p_coll_type value
* @param  p_doc_status value
* @param  p_doc_type value
* @param  p_doc_dir value
* @param  p_coll_id value
* @param  p_coll_standard value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Defaults Collaboration Status
*/
    PROCEDURE DEFAULT_COLLABORATION_STATUS(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         x_coll_status                          IN  OUT NOCOPY VARCHAR2,
         p_app_id                               IN  VARCHAR2,
         p_coll_type                            IN  VARCHAR2,
         p_doc_status                           IN  VARCHAR2,
         p_doc_type                             IN  VARCHAR2,
         p_doc_dir                              IN  VARCHAR2,
         p_coll_id                              IN  NUMBER,
         p_coll_standard                        IN  VARCHAR2  DEFAULT NULL);



  -- Name
  --   FIND_COLLABORATION_ID
  -- Purpose
  --   This is the public procedure which may be used to get the collaboration id
  --   for a particular transaction.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure may be used to get the collaboration id for a particular transaction.
* @param  x_return_status value
* @param  x_msg_data value
* @param  x_coll_id value
* @param  p_app_id value
* @param  p_coll_type value
* @param  p_ref_id value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_xmlg_int_transaction_type value
* @param  p_xmlg_int_transaction_subtype value
* @param  p_tr_partner_id value
* @param  p_tr_partner_site value
* @param  p_tr_partner_type value
* @param  p_xmlg_document_id value
* @param  p_doc_dir value
* @param  p_xmlg_msg_id value
* @param  p_unique1 value
* @param  p_unique2 value
* @param  p_unique3 value
* @param  p_unique4 value
* @param  p_unique5 value
* @param p_xmlg_internal_control_number value
* @param  p_xml_event_key value
* @param  p_collaboration_standard value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Finds Collaboration Id
*/
     PROCEDURE FIND_COLLABORATION_ID(
            x_return_status                        OUT NOCOPY VARCHAR2,
            x_msg_data                             OUT NOCOPY VARCHAR2,
            x_coll_id                              OUT NOCOPY NUMBER,
            p_app_id                               IN  VARCHAR2 DEFAULT NULL,
	    p_coll_type                            IN  VARCHAR2 DEFAULT NULL,
            p_ref_id                               IN  VARCHAR2 DEFAULT NULL,
            p_xmlg_transaction_type                IN  VARCHAR2 DEFAULT NULL,
            p_xmlg_transaction_subtype             IN  VARCHAR2 DEFAULT NULL,
            p_xmlg_int_transaction_type            IN  VARCHAR2 DEFAULT NULL,--NOT USED FOR THIS RELEASE
            p_xmlg_int_transaction_subtype         IN  VARCHAR2 DEFAULT NULL,--NOT USED FOR THIS RELEASE
            p_tr_partner_id                        IN  VARCHAR2 DEFAULT NULL,
            p_tr_partner_site                      IN  VARCHAR2 DEFAULT NULL,
            p_tr_partner_type                      IN  VARCHAR2 DEFAULT NULL,
            p_xmlg_document_id                     IN  VARCHAR2 DEFAULT NULL,
            p_doc_dir                              IN  VARCHAR2 DEFAULT NULL,
            p_xmlg_msg_id                          IN  VARCHAR2 DEFAULT NULL,
            p_unique1                              IN  VARCHAR2 DEFAULT NULL,
            p_unique2                              IN  VARCHAR2 DEFAULT NULL,
            p_unique3                              IN  VARCHAR2 DEFAULT NULL,
            p_unique4                              IN  VARCHAR2 DEFAULT NULL,
            p_unique5                              IN  VARCHAR2 DEFAULT NULL,
            p_xmlg_internal_control_number         IN  NUMBER DEFAULT NULL,
            p_xml_event_key                       IN  VARCHAR2 DEFAULT NULL,
            p_collaboration_standard               IN  VARCHAR2 DEFAULT NULL);


  -- Name
  --   ADD_COLLABORATION
  -- Purpose
  --   This is the public procedure which decides whether the collaboration nneds to be created
  --   or updated.
  -- Arguments
  --
  -- Notes
  --   No specific notes.
/*#
* This procedure which decides whether the collaboration needs to be created or updated
* @param  x_return_status value
* @param  x_msg_data value
* @param  p_coll_id value
* @param  p_app_id value
* @param  p_ref_id value
* @param  p_rel_no value
* @param  p_doc_no value
* @param  p_doc_rev_no value
* @param  p_xmlg_transaction_type value
* @param  p_xmlg_transaction_subtype value
* @param  p_xmlg_document_id value
* @param  p_resend_flag value
* @param  p_resend_count value
* @param  p_disposition value
* @param  p_coll_status value
* @param   p_coll_type value
* @param p_coll_pt value
* @param p_doc_type value
* @param p_doc_dir value
* @param  p_org_ref value
* @param p_doc_status value
* @param  p_notification_id value
* @param  p_msg_text value
* @param  p_attr1 value
* @param  p_attr2 value
* @param  p_attr3 value
* @param  p_attr4 value
* @param  p_attr5 value
* @param  p_attr6 value
* @param  p_attr7 value
* @param  p_attr8 value
* @param  p_attr9 value
* @param  p_attr10 value
* @param  p_attr11 value
* @param  p_attr12 value
* @param  p_attr13 value
* @param  p_attr14 value
* @param  p_attr15 value
* @param  p_unique1 value
* @param  p_unique2 value
* @param  p_unique3 value
* @param  p_unique4 value
* @param  p_unique5 value
* @param  p_tr_partner_type value
* @param  p_tr_partner_id value
* @param  p_tr_partner_site value
* @param  p_sender_component value
* @param  p_RosettaNet_check_required value
* @param   x_dtl_coll_id value
* @param  p_xmlg_internal_control_number value
* @param  p_partner_doc_no value
* @param  p_org_id value
* @param p_init_date value
* @param p_doc_creation_date value
* @param p_doc_revision_date value
* @param p_doc_owner value
* @param p_xmlg_int_transaction_type value
* @param p_xmlg_int_transaction_subtype value
* @param p_xml_event_key value
* @param p_collaboration_standard value
* @param p_attribute1 value
* @param p_attribute2 value
* @param p_attribute3 value
* @param p_attribute4 value
* @param p_attribute5 value
* @param p_attribute6 value
* @param p_attribute7 value
* @param p_attribute8 value
* @param p_attribute9 value
* @param p_attribute10 value
* @param p_attribute11 value
* @param p_attribute12 value
* @param p_attribute13 value
* @param p_attribute14 value
* @param p_attribute15 value
* @param p_dattribute1 value
* @param p_dattribute2 value
* @param p_dattribute3 value
* @param p_dattribute4 value
* @param p_dattribute5 value
* @param p_xmlg_msg_id value
* @param p_owner_role value
* @rep:scope private
* @rep:lifecycle active
* @rep:displayname Adds Collaboration
 */
    PROCEDURE ADD_COLLABORATION(
         x_return_status                        OUT NOCOPY VARCHAR2,
         x_msg_data                             OUT NOCOPY VARCHAR2,
         p_coll_id                              IN  NUMBER DEFAULT NULL,
         p_app_id                               IN  VARCHAR2 DEFAULT NULL,
         p_ref_id                               IN  VARCHAR2 DEFAULT NULL,
         p_rel_no                               IN  VARCHAR2 DEFAULT NULL,
         p_doc_no                               IN  VARCHAR2 DEFAULT NULL,
         p_doc_rev_no                           IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_transaction_type                IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_transaction_subtype             IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_document_id                     IN  VARCHAR2 DEFAULT NULL,
         p_resend_flag                          IN  VARCHAR2 DEFAULT NULL,
         p_resend_count                         IN  NUMBER DEFAULT NULL,
         p_disposition                          IN  VARCHAR2 DEFAULT NULL,
         p_coll_status                          IN  VARCHAR2 DEFAULT NULL,
         p_coll_type                            IN  VARCHAR2 DEFAULT NULL,
         p_coll_pt                              IN  VARCHAR2 DEFAULT 'APPS',
         p_doc_type                             IN  VARCHAR2 DEFAULT NULL,
         p_doc_dir                              IN  VARCHAR2 DEFAULT NULL,
         p_org_ref                              IN  VARCHAR2 DEFAULT NULL,
         p_doc_status                           IN  VARCHAR2 DEFAULT 'SUCCESS',
         p_notification_id                      IN  VARCHAR2 DEFAULT NULL,
         p_msg_text                             IN  VARCHAR2 ,
         p_attr1                                IN  VARCHAR2 DEFAULT NULL,
         p_attr2                                IN  VARCHAR2 DEFAULT NULL,
         p_attr3                                IN  VARCHAR2 DEFAULT NULL,
         p_attr4                                IN  VARCHAR2 DEFAULT NULL,
         p_attr5                                IN  VARCHAR2 DEFAULT NULL,
         p_attr6                                IN  VARCHAR2 DEFAULT NULL,
         p_attr7                                IN  VARCHAR2 DEFAULT NULL,
         p_attr8                                IN  VARCHAR2 DEFAULT NULL,
         p_attr9                                IN  VARCHAR2 DEFAULT NULL,
         p_attr10                               IN  VARCHAR2 DEFAULT NULL,
         p_attr11                               IN  VARCHAR2 DEFAULT NULL,
         p_attr12                               IN  VARCHAR2 DEFAULT NULL,
         p_attr13                               IN  VARCHAR2 DEFAULT NULL,
         p_attr14                               IN  VARCHAR2 DEFAULT NULL,
         p_attr15                               IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_msg_id                          IN  VARCHAR2,
         p_unique1                              IN  VARCHAR2 DEFAULT NULL,
         p_unique2                              IN  VARCHAR2 DEFAULT NULL,
         p_unique3                              IN  VARCHAR2 DEFAULT NULL,
         p_unique4                              IN  VARCHAR2 DEFAULT NULL,
         p_unique5                              IN  VARCHAR2 DEFAULT NULL,
         p_tr_partner_type                      IN  VARCHAR2 DEFAULT NULL,
         p_tr_partner_id                        IN  VARCHAR2 DEFAULT NULL,
         p_tr_partner_site                      IN  VARCHAR2 DEFAULT NULL,
         p_sender_component                     IN  VARCHAR2 DEFAULT NULL,
         p_rosettanet_check_required            IN  BOOLEAN  DEFAULT NULL,
         x_dtl_coll_id                          OUT NOCOPY   NUMBER,
         p_xmlg_internal_control_number         IN  NUMBER   DEFAULT NULL,
         p_partner_doc_no                       IN  VARCHAR2 DEFAULT NULL,
         p_org_id                               IN  NUMBER   DEFAULT NULL,
         p_init_date                            IN  DATE     DEFAULT SYSDATE,
         p_doc_creation_date                    IN  DATE     DEFAULT NULL,
         p_doc_revision_date                    IN  DATE     DEFAULT NULL,
         p_doc_owner                            IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_int_transaction_type            IN  VARCHAR2 DEFAULT NULL,
         p_xmlg_int_transaction_subtype         IN  VARCHAR2 DEFAULT NULL,
         p_xml_event_key                        IN  VARCHAR2 DEFAULT NULL,
         p_collaboration_standard               IN  VARCHAR2 DEFAULT NULL,
         p_attribute1                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute2                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute3                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute4                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute5                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute6                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute7                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute8                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute9                           IN  VARCHAR2 DEFAULT NULL,
         p_attribute10                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute11                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute12                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute13                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute14                          IN  VARCHAR2 DEFAULT NULL,
         p_attribute15                          IN  VARCHAR2 DEFAULT NULL,
         p_dattribute1                          IN  DATE     DEFAULT NULL,
         p_dattribute2                          IN  DATE     DEFAULT NULL,
         p_dattribute3                          IN  DATE     DEFAULT NULL,
         p_dattribute4                          IN  DATE     DEFAULT NULL,
         p_dattribute5                          IN  DATE     DEFAULT NULL,
         p_owner_role                           IN  VARCHAR2 DEFAULT NULL  );

END CLN_CH_COLLABORATION_PKG;

 

/
