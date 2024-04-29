--------------------------------------------------------
--  DDL for Package IGF_SL_UPLOAD_XML
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_UPLOAD_XML" AUTHID CURRENT_USER AS
/* $Header: IGFSL26S.pls 120.2 2006/04/19 07:00:53 ugummall noship $ */

  /*************************************************************
  Created By : ugummall
  Date Created On : 2004/09/21
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE main(errbuf          OUT      NOCOPY    VARCHAR2,
               retcode         OUT      NOCOPY    NUMBER,
               p_file_path     IN               VARCHAR2
              ) ;
PROCEDURE main_response(errbuf          OUT NOCOPY    VARCHAR2,
                        retcode         OUT NOCOPY    NUMBER,
                        p_document_id   IN            VARCHAR2
                       );
PROCEDURE upload_xml(
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   );
PROCEDURE set_nls_fmt(PARAM in VARCHAR2);

FUNCTION  get_created_by RETURN NUMBER;
FUNCTION  get_creation_date RETURN DATE;
FUNCTION  get_last_updated_by RETURN NUMBER;
FUNCTION  get_last_update_date RETURN DATE;
FUNCTION  get_last_update_login RETURN NUMBER;

PROCEDURE get_datetime(
                       PARAM in VARCHAR2,
                       OUTPARAM  OUT NOCOPY VARCHAR2
                      );
PROCEDURE get_date(
                       PARAM in VARCHAR2,
                       OUTPARAM  OUT NOCOPY VARCHAR2
                      );
PROCEDURE launch_request(
      itemtype    IN              VARCHAR2,
      itemkey     IN              VARCHAR2,
      actid       IN              NUMBER,
      funcmode    IN              VARCHAR2,
      resultout   OUT NOCOPY      VARCHAR2
   );
PROCEDURE update_rs_respcode(p_rec_id IN VARCHAR2, p_resp_code IN VARCHAR2);

PROCEDURE update_rcptdate_respcode(p_doc_id IN VARCHAR2, p_receipt_date IN VARCHAR2);


END igf_sl_upload_xml;

 

/
