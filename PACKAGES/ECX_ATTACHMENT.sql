--------------------------------------------------------
--  DDL for Package ECX_ATTACHMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_ATTACHMENT" AUTHID CURRENT_USER AS
-- $Header: ECXATCHS.pls 120.3 2005/10/30 23:18:36 susaha ship $
-- The name used in ecx_util.g_event to record the attachment records
ECX_UTIL_EVENT_ATTACHMENT   CONSTANT VARCHAR2(15)   := 'ECX_ATTACHMENTS';

-- Attachment types with respect to FND attachment framework under
-- EMBEDDED mode. Currently, only EMBEDDED_LOB_DATA_TYPE is supported.
EMBEDDED_SHORTTEXT_DATA_TYPE   CONSTANT NUMBER         := 1;
EMBEDDED_LONGTEXT_DATA_TYPE    CONSTANT NUMBER         := 2;
EMBEDDED_LONGRAW_DATA_TYPE     CONSTANT NUMBER         := 4;
EMBEDDED_LOB_DATA_TYPE         CONSTANT NUMBER         := 6;


---------------------------------------------------------------------
-- PROCEDURE NAME: deposit_blob_attachment
--
-- DESCRIPTION:
--
-- This procedure deposit OTA received attachment files into
-- FND_DOCUMENTS for EMBEDDED mode. It is not intended for
-- upper layer uses. Instead, the upper layers are responsible
-- to deposit attachment files by themselves. the i_main_doc_id
-- is used internally to associate multipe attachment files of
-- a same main doc (or business object).
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE deposit_blob_attachment(
             i_main_doc_id           IN OUT NOCOPY NUMBER,
             i_file_name             IN       VARCHAR2,
             i_file_content_type     IN       VARCHAR2   DEFAULT NULL,
             i_file_data             IN       BLOB,
             i_expire_date           IN       DATE,
             i_lang                  IN       VARCHAR2,
             i_ora_charset           IN       VARCHAR2,
             i_file_format           IN       VARCHAR2   DEFAULT NULL,
             x_file_id               OUT NOCOPY NUMBER
            );



---------------------------------------------------------------------
-- PROCEDURE NAME: formulate_content_id
--
-- DESCRIPTION:
--
-- This procedure is called in the user codes. It formualtes a content
-- ID based on the provided information. The entity_name IN parameter
-- should not be NULL.
--
-- CHANGE HISTORY:
--
--------------------------------------------------------------------
PROCEDURE formulate_content_id(
              i_file_id             IN        NUMBER,
              i_entity_name         IN        VARCHAR2,
              i_pk1_value           IN        VARCHAR2,
              i_pk2_value           IN        VARCHAR2,
              i_pk3_value           IN        VARCHAR2,
              i_pk4_value           IN        VARCHAR2,
              i_pk5_value           IN        VARCHAR2,
              x_cid                 OUT NOCOPY VARCHAR2
           );

---------------------------------------------------------------------
-- PROCEDURE NAME: register_attachment
--
-- DESCRIPTION:
--
-- This procedure should be called from the Message Designer's actions
-- by user code. Users may first deposit an attachment using the
-- provided deposit_XX_attachment API. Immediately afterwards, the users
-- call the register_attachment API to inform/register this attachment
-- deposition with XML-Gateway. In the case when the users have deposited
-- their attachments by themselve to the appropriate attachment repository,
-- the user must still call this register_attachment to inform XML-Gateway.
-- i_cid is a user provided id to denote a given attachment. It has
-- significance only to the user, not to the XML-Gateway. This i_cid is
-- later on packaged into an outgoing MIME message as content-type MIME
-- header field by OTA. The i_file_id is an unique key enable retrieval
-- of an attachment from some repository, while the i_data_type denotes the
-- type (blob, short_text, long_text, or long_raw) of the attachment. The
-- i_file_id and i_data_type together facilitate the retrieval of an
-- attachment from a specific attachment repository. This register_attachment
-- internally package the i_cid and i_file_id into the ECX_ATTACHMENT field of
-- the ecx_utils.g_event. Repeated attachment depositions cause repeated
-- register_attachment. Ultimately, a serial of i_cid and i_file_id are
-- concanated and packed into the ECX_ATTACHMENT filed of ecx_utils.g_event.
-- Among the serial of i_cid and i_file_id, it is expected that no different
-- i_file_id can be associated with a same i_cid
--
-- CHANGE HISTORY:
--
PROCEDURE register_attachment(
             i_cid                   IN       VARCHAR2,
             i_file_id               IN       NUMBER,
             i_data_type             IN       NUMBER
            );

---------------------------------------------------------------------
-- PROCEDURE NAME: register_attachment
--
-- DESCRIPTION:
--
-- This procedure is called in the user codes. It register a user
-- deposited attachment with the XML-Gateway, so that the XML-Gateway
-- may later construct a MIME message to encapuslate this attachment.
--
-- CHANGE HISTORY:
--
PROCEDURE register_attachment(
             i_entity_name           IN        VARCHAR2,
             i_pk1_value             IN        VARCHAR2,
             i_pk2_value             IN        VARCHAR2,
             i_pk3_value             IN        VARCHAR2,
             i_pk4_value             IN        VARCHAR2,
             i_pk5_value             IN        VARCHAR2,
             i_file_id               IN        NUMBER,
             i_data_type             IN        NUMBER,
             x_cid                   OUT NOCOPY VARCHAR2
            );


---------------------------------------------------------------------
-- PROCEDURE NAME: register_attachment_offline
--
-- DESCRIPTION:
--
-- This procedure is called in the user codes for BES cases. The user
-- register attachment maps first before raising a business event. As
-- part of the event, there is a generate function to produce XML
-- business document without attachment. Therefore, it is necessary
-- to call this register_attachment_offline beforehand.
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE register_attachment_offline(
             i_cid                   IN       VARCHAR2,
             i_file_id               IN       NUMBER,
             i_data_type             IN       NUMBER
            );

---------------------------------------------------------------------
-- PROCEDURE NAME: register_attachment_offline
--
-- DESCRIPTION:
--
-- This procedure is called in the user codes for BES cases. The user
-- register attachment maps first before raising a business event. As
-- part of the event, there is a generate function to produce XML
-- business document without attachment. Therefore, it is necessary
-- to call this register_attachment_offline beforehand. This procedure
-- differs from the other register_attachment_offline in that its
-- parameters are different. It does not pre-construct an unique
-- CID before calling.
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE register_attachment_offline(
             i_entity_name           IN        VARCHAR2,
             i_pk1_value             IN        VARCHAR2,
             i_pk2_value             IN        VARCHAR2,
             i_pk3_value             IN        VARCHAR2,
             i_pk4_value             IN        VARCHAR2,
             i_pk5_value             IN        VARCHAR2,
             i_file_id               IN        NUMBER,
             i_data_type             IN        NUMBER,
             x_cid                   OUT NOCOPY VARCHAR2
            );


---------------------------------------------------------------------
-- PROCEDURE NAME: remove_attachmentMaps_offline
--
-- DESCRIPTION:
--
-- This procedure is called in the user codes for BES cases. The user
-- register attachment maps offline first, it then use this
-- remove_attachmentMaps_offline to retrieve and remove the entire
-- attachment mapping string before putting it as part of the
-- event parameters using wf_event.AddParameterToList function.
-- Note, this method remove the existing maps as well.
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE remove_attachmentMaps_offline(
              x_attachment_maps     OUT NOCOPY VARCHAR2);

---------------------------------------------------------------------
-- PROCEDURE NAME: map_attachments
--
-- DESCRIPTION:
--
-- This procedure is called by the Message Designer ECX_OUTBOUND right
-- after it enqueues the outgoing business document in outbound AQ. This
-- procedure is responsible to maintain mappings between the main business
-- document and its attachments.
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE map_attachments(
              i_msgid              IN       RAW
             );

---------------------------------------------------------------------
-- PROCEDURE NAME: map_attachments
--
-- DESCRIPTION:
--
-- This procedure is called after the XML doc is enqueues to
-- outbound AQ. This procedure is responsible to maintain mappings
-- between the main business document and its attachments based
-- based on information stored in the event
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE map_attachments(
              i_event              IN       WF_EVENT_T,
              i_msgid              IN       RAW
             );

---------------------------------------------------------------------
-- PROCEDURE NAME: remap_attachments
--
-- DESCRIPTION:
--
-- This procedure is called by ECX_INBOUND_TRIG for the passthrough
-- cases. Basically, the XML-Gateway inbound processing layer is
-- responsible to maintain attachment mapping information for
-- passthrough business documents. The i_msgid IN parameter
-- is the AQ message ID for the passthrough business document once
-- it is pushed into the ECX_OUTQUEUE after all the passthrough
-- processing has been completed.
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE remap_attachments(
              i_msgid              IN       RAW
             );


---------------------------------------------------------------------
-- PROCEDURE NAME: retrieve_attachment
--
-- DESCRIPTION:
--
-- This procedure is responsible to retrieve an attachment based on
-- provided msgId and cId. It can be used in two places. First, the
-- OTA java layer uses this procedure to retrieve attachments and
-- formulates outbound MIME messages. Second, the inbound portion
-- (receiving side) of the Message Designer uses this procedure to
-- retrieve attachments. In the second case, the msgId must be the
-- original enqueue msgId the OTA obtains when it deposites
-- received MIME attachment parts on inbound side.
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE retrieve_attachment(
              i_msgid              IN       RAW,
              i_cid                IN       VARCHAR2,
              x_file_name          OUT NOCOPY VARCHAR2,
              x_file_content_type  OUT NOCOPY VARCHAR2,
              x_file_data          OUT NOCOPY BLOB,
              x_ora_charset        OUT NOCOPY VARCHAR2,
              x_file_format        OUT NOCOPY VARCHAR2
           );


---------------------------------------------------------------------
-- PROCEDURE NAME: retrieve_attachment
--
-- DESCRIPTION:
--
-- This procedure is responsible to retrieve an attachment based on
-- provided msgId and cId. It can be used in two places. First, the
-- OTA java layer uses this procedure to retrieve attachments and
-- formulates outbound MIME messages. Second, the inbound portion
-- (receiving side) of the Message Designer uses this procedure to
-- retrieve attachments. In the second case, the msgId must be the
-- original enqueue msgId the OTA obtains when it deposites
-- received MIME attachment parts on inbound side. This API differs
-- from the previous retrieve_attachment API in that it returns
-- language as well. The language is useful to transmitted across
-- the wire to destination sides. This new retrieve_attachment is
-- created, so that existing code dependent on the previous
-- retrieve_attachment will not break.
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE retrieve_attachment(
              i_msgid              IN       RAW,
              i_cid                IN       VARCHAR2,
              x_file_name          OUT NOCOPY VARCHAR2,
              x_file_content_type  OUT NOCOPY VARCHAR2,
              x_file_data          OUT NOCOPY BLOB,
              x_language           OUT NOCOPY VARCHAR2,
              x_ora_charset        OUT NOCOPY VARCHAR2,
              x_file_format        OUT NOCOPY VARCHAR2
           );

---------------------------------------------------------------------
-- PROCEDURE NAME: retrieve_attachment
--
-- DESCRIPTION:
--
-- This procedure is responsible to retrieve an attachment based on
-- provided fileId and dataType. It can be used in one places. The
-- WS java layer uses this procedure to retrieve attachments and
-- formulates outbound MIME messages. This API differs
-- from the previous retrieve_attachment API in that it returns
-- language and it takes fileId and dataType as inputs. The language
-- is useful to transmitted across the wire to destination sides.
-- This new retrieve_attachment is created for the WS,
-- so that existing code dependent on the previous
-- retrieve_attachment will not break.
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE retrieve_attachment(
              i_file_id            IN       NUMBER,
              i_data_type          IN       NUMBER,
              x_file_name          OUT NOCOPY VARCHAR2,
              x_file_content_type  OUT NOCOPY VARCHAR2,
              x_file_data          OUT NOCOPY BLOB,
              x_language           OUT NOCOPY VARCHAR2,
              x_ora_charset        OUT NOCOPY VARCHAR2,
              x_file_format        OUT NOCOPY VARCHAR2
           );


---------------------------------------------------------------------
-- PROCEDURE NAME: reconfig_attachment
--
-- DESCRIPTION:
--
-- This procedure is called by user code. They may repeatedly retrieve
-- their attachment contents by calling retrieve_attachment first. Subseqeuntly,
-- if they choose to reconfig their attachments by resetting appropriate
-- mapping vakues in the fnd_attached_documents table, they may use this
-- reconfig_attachment procedure. On the other hand, the users may skip this
-- procedure call, and instead just save the retrieve BLOB (attachment contents)
-- by themselves.
--
-- CHANGE HISTORY:
--
---------------------------------------------------------------------
PROCEDURE reconfig_attachment(
              i_msgid              IN       RAW,
              i_cid                IN       VARCHAR2,
              i_entity_name        IN       VARCHAR2,
              i_pk1_value          IN       VARCHAR2,
              i_pk2_value          IN       VARCHAR2,
              i_pk3_value          IN       VARCHAR2,
              i_pk4_value          IN       VARCHAR2,
              i_pk5_value          IN       VARCHAR2,
              i_program_app_id     IN       NUMBER,
              i_program_id         IN       NUMBER,
              i_request_id         IN       NUMBER,
              x_document_id        OUT NOCOPY NUMBER
           );

END ecx_attachment;

 

/
