--------------------------------------------------------
--  DDL for Package IGI_IMP_IAC_TRANSFER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_IMP_IAC_TRANSFER_PKG" AUTHID CURRENT_USER AS
-- $Header: igiimtds.pls 120.4.12000000.2 2007/10/16 14:29:34 sharoy ship $
    PROCEDURE TRANSFER_DATA ( errbuf           OUT NOCOPY   VARCHAR2 ,
			      retcode          OUT NOCOPY   NUMBER ,
			      p_book_type_code       VARCHAR2 ,
			      p_category_id          NUMBER,
                  p_event_id             number    );   --R12 uptake
END; --package spec

 

/
