--------------------------------------------------------
--  DDL for Package IGS_PS_WF_EVENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_WF_EVENT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPS82S.pls 115.5 2003/06/20 05:47:18 jdeekoll ship $ */

 ------------------------------------------------------------------------------------
  --Created by  : smanglm ( Oracle IDC)
  --Date created: 19-JUL-2001
  --
  --Purpose:  Created as part of the build for DLD Unit Section Enrollment Information
  --          This package deals with raising of Business Event. This package has the
  --          following procedure:
  --             i)  wf_create_event - Raises the event
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --jdeekoll    06-May-03       Added 4 procedure as part of HR Integration(# 2833853)
  -------------------------------------------------------------------------------------

 PROCEDURE wf_create_event(
                              p_uoo_id                       IN  NUMBER,
                              p_usec_occur_id                IN  NUMBER DEFAULT NULL,
                              p_event_type                   IN  VARCHAR2,
                              p_message                     OUT NOCOPY  VARCHAR2
                            );


PROCEDURE fac_exceed_wl_event(errbuf OUT NOCOPY VARCHAR2,
                               retcode OUT NOCOPY NUMBER,
                                p_c_cal_inst IN VARCHAR2);


PROCEDURE generate_faculty_list(itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                resultout       out NOCOPY varchar2
                                );

PROCEDURE generate_faculty_header(document_id	in      varchar2,
                                   display_type in      Varchar2,
                                  document      in out  NOCOPY clob,
                                   document_type	in out NOCOPY  varchar2
                                  );

PROCEDURE generate_faculty_body  (document_id in varchar2,
		                  display_type in Varchar2,
                                  document      in out NOCOPY clob,
                                  document_type in out NOCOPY  varchar2
                                 );

END IGS_PS_WF_EVENT_PKG;

 

/
