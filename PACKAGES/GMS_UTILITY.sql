--------------------------------------------------------
--  DDL for Package GMS_UTILITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_UTILITY" AUTHID CURRENT_USER AS
--  $Header: gmsutils.pls 115.11 2003/01/15 20:02:15 aaggarwa ship $

Function GET_AWARD_NUMBER(P_Award_Id    IN NUMBER) RETURN VARCHAR2;

/*-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------*/
procedure gms_util_fck (x_sob_id              IN NUMBER,
                        x_packet_id           IN NUMBER,
                        x_fcmode              IN VARCHAR2 DEFAULT 'C',
                        x_override            IN BOOLEAN,
                        x_partial             IN VARCHAR2 DEFAULT 'N',
                        x_user_id             IN NUMBER DEFAULT NULL,
                        x_user_resp_id        IN NUMBER DEFAULT NULL,
                        x_execute             IN VARCHAR2 DEFAULT 'N',
                        x_gms_return_code     IN OUT NOCOPY  VARCHAR2,
                        x_gl_return_code      IN OUT NOCOPY  VARCHAR2
                       );

/*-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------*/
procedure gms_util_pc_fck (x_sob_id           IN NUMBER,
                        x_packet_id           IN NUMBER,
                        x_fcmode              IN VARCHAR2 DEFAULT 'C',
                        x_override            IN VARCHAR2 DEFAULT 'N',
                        x_partial             IN VARCHAR2 DEFAULT 'N',
                        x_user_id             IN NUMBER DEFAULT NULL,
                        x_user_resp_id        IN NUMBER DEFAULT NULL,
                        x_execute             IN VARCHAR2 DEFAULT 'N',
                        x_gms_return_code     IN OUT NOCOPY  VARCHAR2
                       );

/*-----------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------*/
procedure gms_util_gl_return_code(x_packet_id         IN NUMBER,
				  x_mode	      IN varchar2,
                                  x_gl_return_code    IN OUT NOCOPY  VARCHAR2,
                                  x_gms_return_code   IN VARCHAR2,
                                  x_partial_resv_flag IN VARCHAR2
                                  );


END GMS_UTILITY ;

 

/
