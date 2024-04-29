--------------------------------------------------------
--  DDL for Package CLN_SHOWSHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CLN_SHOWSHIP_PKG" AUTHID CURRENT_USER AS
   /* $Header: CLNSHSPS.pls 115.4 2003/06/28 09:17:22 kkram noship $ */

   /*=======================================================================+
   | FILENAME
   |   CLNSHSPS.sql
   |
   | DESCRIPTION
   |   PL/SQL spec for package:  CLN_SHOWSHIP_PKG
   |
   | NOTES
   |   Created 1/10/03 chiung-fu.shih
   *=====================================================================*/

   PROCEDURE Showship_Raise_Event(errbuf         OUT NOCOPY      VARCHAR2,
                                  retcode        OUT NOCOPY      VARCHAR2,
                                  p_delivery_id  IN              NUMBER,
                                  dummy1         IN              VARCHAR2 DEFAULT NULL,
                                  dummy2         IN              VARCHAR2 DEFAULT NULL,
                                  dummy3         IN              VARCHAR2 DEFAULT NULL,
                                  dummy4         IN              VARCHAR2 DEFAULT NULL,
                                  dummy5         IN              VARCHAR2 DEFAULT NULL,
                                  dummy6         IN              VARCHAR2 DEFAULT NULL,
                                  dummy7         IN              VARCHAR2 DEFAULT NULL,
                                  dummy8         IN              VARCHAR2 DEFAULT NULL,
                                  dummy9         IN              VARCHAR2 DEFAULT NULL,
                                  dummy10        IN              VARCHAR2 DEFAULT NULL,
                                  dummy11        IN              VARCHAR2 DEFAULT NULL,
                                  dummy12        IN              VARCHAR2 DEFAULT NULL,
                                  dummy13        IN              VARCHAR2 DEFAULT NULL,
                                  dummy14        IN              VARCHAR2 DEFAULT NULL,
                                  dummy15        IN              VARCHAR2 DEFAULT NULL,
                                  dummy16        IN              VARCHAR2 DEFAULT NULL,
                                  dummy17        IN              VARCHAR2 DEFAULT NULL,
                                  dummy18        IN              VARCHAR2 DEFAULT NULL,
                                  dummy19        IN              VARCHAR2 DEFAULT NULL,
                                  dummy20        IN              VARCHAR2 DEFAULT NULL,
                                  dummy21        IN              VARCHAR2 DEFAULT NULL,
                                  dummy22        IN              VARCHAR2 DEFAULT NULL,
                                  dummy23        IN              VARCHAR2 DEFAULT NULL,
                                  dummy24        IN              VARCHAR2 DEFAULT NULL,
                                  dummy25        IN              VARCHAR2 DEFAULT NULL,
                                  dummy26        IN              VARCHAR2 DEFAULT NULL,
                                  dummy27        IN              VARCHAR2 DEFAULT NULL,
                                  dummy28        IN              VARCHAR2 DEFAULT NULL,
                                  dummy29        IN              VARCHAR2 DEFAULT NULL,
dummy30	IN              VARCHAR2 DEFAULT NULL,
dummy31	IN              VARCHAR2 DEFAULT NULL,
dummy32	IN              VARCHAR2 DEFAULT NULL,
dummy33	IN              VARCHAR2 DEFAULT NULL,
dummy34	IN              VARCHAR2 DEFAULT NULL,
dummy35	IN              VARCHAR2 DEFAULT NULL,
dummy36	IN              VARCHAR2 DEFAULT NULL,
dummy37	IN              VARCHAR2 DEFAULT NULL,
dummy38	IN              VARCHAR2 DEFAULT NULL,
dummy39	IN              VARCHAR2 DEFAULT NULL,
dummy40	IN              VARCHAR2 DEFAULT NULL,
dummy41	IN              VARCHAR2 DEFAULT NULL,
dummy42	IN              VARCHAR2 DEFAULT NULL,
dummy43	IN              VARCHAR2 DEFAULT NULL,
dummy44	IN              VARCHAR2 DEFAULT NULL,
dummy45	IN              VARCHAR2 DEFAULT NULL,
dummy46	IN              VARCHAR2 DEFAULT NULL,
dummy47	IN              VARCHAR2 DEFAULT NULL,
dummy48	IN              VARCHAR2 DEFAULT NULL,
dummy49	IN              VARCHAR2 DEFAULT NULL,
dummy50	IN              VARCHAR2 DEFAULT NULL,
dummy51	IN              VARCHAR2 DEFAULT NULL,
dummy52	IN              VARCHAR2 DEFAULT NULL,
dummy53	IN              VARCHAR2 DEFAULT NULL,
dummy54	IN              VARCHAR2 DEFAULT NULL,
dummy55	IN              VARCHAR2 DEFAULT NULL,
dummy56	IN              VARCHAR2 DEFAULT NULL,
dummy57	IN              VARCHAR2 DEFAULT NULL,
dummy58	IN              VARCHAR2 DEFAULT NULL,
dummy59	IN              VARCHAR2 DEFAULT NULL,
dummy60	IN              VARCHAR2 DEFAULT NULL,
dummy61	IN              VARCHAR2 DEFAULT NULL,
dummy62	IN              VARCHAR2 DEFAULT NULL,
dummy63	IN              VARCHAR2 DEFAULT NULL,
dummy64	IN              VARCHAR2 DEFAULT NULL,
dummy65	IN              VARCHAR2 DEFAULT NULL,
dummy66	IN              VARCHAR2 DEFAULT NULL,
dummy67	IN              VARCHAR2 DEFAULT NULL,
dummy68	IN              VARCHAR2 DEFAULT NULL,
dummy69	IN              VARCHAR2 DEFAULT NULL,
dummy70	IN              VARCHAR2 DEFAULT NULL,
dummy71	IN              VARCHAR2 DEFAULT NULL,
dummy72	IN              VARCHAR2 DEFAULT NULL,
dummy73	IN              VARCHAR2 DEFAULT NULL,
dummy74	IN              VARCHAR2 DEFAULT NULL,
dummy75	IN              VARCHAR2 DEFAULT NULL,
dummy76	IN              VARCHAR2 DEFAULT NULL,
dummy77	IN              VARCHAR2 DEFAULT NULL,
dummy78	IN              VARCHAR2 DEFAULT NULL,
dummy79	IN              VARCHAR2 DEFAULT NULL,
dummy80	IN              VARCHAR2 DEFAULT NULL,
dummy81	IN              VARCHAR2 DEFAULT NULL,
dummy82	IN              VARCHAR2 DEFAULT NULL,
dummy83	IN              VARCHAR2 DEFAULT NULL,
dummy84	IN              VARCHAR2 DEFAULT NULL,
dummy85	IN              VARCHAR2 DEFAULT NULL,
dummy86	IN              VARCHAR2 DEFAULT NULL,
dummy87	IN              VARCHAR2 DEFAULT NULL,
dummy88	IN              VARCHAR2 DEFAULT NULL,
dummy89	IN              VARCHAR2 DEFAULT NULL,
dummy90	IN              VARCHAR2 DEFAULT NULL,
dummy91	IN              VARCHAR2 DEFAULT NULL,
dummy92	IN              VARCHAR2 DEFAULT NULL,
dummy93	IN              VARCHAR2 DEFAULT NULL,
dummy94	IN              VARCHAR2 DEFAULT NULL,
dummy95	IN              VARCHAR2 DEFAULT NULL,
dummy96	IN              VARCHAR2 DEFAULT NULL,
dummy97	IN              VARCHAR2 DEFAULT NULL,
dummy98	IN              VARCHAR2 DEFAULT NULL,
dummy99	IN              VARCHAR2 DEFAULT NULL);

END CLN_SHOWSHIP_PKG;

 

/
