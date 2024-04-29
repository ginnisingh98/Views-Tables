--------------------------------------------------------
--  DDL for Package IGF_AW_FISAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_FISAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAW22S.pls 120.0 2005/09/13 09:52:34 appldev noship $ */
  /*************************************************************
  Created By : ugummall
  Date Created On : 2004/10/04
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

PROCEDURE main  ( errbuf                OUT NOCOPY  VARCHAR2,
                  retcode               OUT NOCOPY  NUMBER,
                  p_award_year          IN          VARCHAR2,
                  p_retain_prev_batches IN          VARCHAR2,
                  p_descrption          IN          VARCHAR2
                );

PROCEDURE generate_aggregate_data ( itemtype        IN VARCHAR2,
                                    itemkey         IN VARCHAR2,
                                    actid           IN NUMBER,
                                    funcmode        IN VARCHAR2,
                                    resultout       OUT NOCOPY VARCHAR2
                                  );

PROCEDURE generate_partII ( document_id	  IN      VARCHAR2,
                            display_type  IN      VARCHAR2,
                            document      IN OUT  NOCOPY CLOB,
                            document_type	IN OUT NOCOPY  VARCHAR2
                          );
END IGF_AW_FISAP_PKG;

 

/
