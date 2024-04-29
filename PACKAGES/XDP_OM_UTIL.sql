--------------------------------------------------------
--  DDL for Package XDP_OM_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."XDP_OM_UTIL" AUTHID CURRENT_USER AS
/* $Header: XDPOMUTS.pls 120.1 2005/06/16 02:09:45 appldev  $ */


--  SUBSCRIBE_SERVICE_FULFILLMENT_DONE
--   Resultout
--     Activity Performed   - Activity was completed without any errors
--
-- Your Description here:

-- ****************    SUBSCRIBE_SERVICE_FULFILLMENT_DONE   *********************

PROCEDURE SUBSCRIBE_SRV_FULFILLMENT_DONE
                                  (itemtype   IN  VARCHAR2,
                                   itemkey    IN  VARCHAR2,
                                   actid      IN  NUMBER,
                                   resultout  OUT NOCOPY VARCHAR2 );

-- ****************    SUBSCRIBE_SERVICE_FULFILLMENT_DONE   *********************

PROCEDURE SUBSCRIBE_XDP_LINE_DONE
                         (itemtype   IN  VARCHAR2,
                          itemkey    IN  VARCHAR2,
                          actid      IN  NUMBER,
                          resultout  OUT NOCOPY VARCHAR2 ) ;

-- ****************    HandleOtherWFFuncmode   *********************

FUNCTION HandleOtherWFFuncmode( funcmode in varchar2) RETURN VARCHAR2 ;


-- ****************    IS_ACTIVATION_REQD   *********************

FUNCTION IS_ACTIVATION_REQD
                    (p_line_id IN NUMBER) RETURN BOOLEAN ;


END XDP_OM_UTIL;

 

/
