--------------------------------------------------------
--  DDL for Package CSF_TDS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_TDS_PUB" AUTHID CURRENT_USER AS
/*$Header: CSFPTDSS.pls 120.0.12010000.2 2008/10/08 13:28:18 gmarwah noship $  */

type t_crs is ref cursor;

G_PKG_NAME          CONSTANT VARCHAR2(30)   := 'CSF_TDS_PUB';
G_CONC_PROGRAM_NAME CONSTANT VARCHAR2(30)   := 'CSFTDPUB';

G_VALID_TRUE  CONSTANT VARCHAR2(1)    := 'Y';
G_VALID_FALSE CONSTANT VARCHAR2(1)    := 'N';
G_DEBUG_P     CONSTANT VARCHAR2(100)  := 'begin dbms_'||'output'||'.put_line(:1); end;';

G_LOG         CONSTANT NUMBER   := FND_FILE.LOG;
G_OUTPUT      CONSTANT NUMBER   := FND_FILE.OUTPUT;

G_DEBUG       BOOLEAN  ;

PROCEDURE PURGE_UNUSED_CACHE (
      errbuf         OUT NOCOPY      VARCHAR2,
      retcode        OUT NOCOPY      VARCHAR2,
      p_start_date   IN              VARCHAR2 DEFAULT NULL,
      p_end_date     IN              VARCHAR2 DEFAULT NULL
   );


  PROCEDURE TDS_ROUTES_TO_BE_CALCULATED(query_id IN NUMBER,config_string IN VARCHAR2,
                user_id IN NUMBER,status OUT NOCOPY  NUMBER , msg OUT NOCOPY  VARCHAR2);


PROCEDURE GEO_DISTANCE (srId IN NUMBER,x1 IN NUMBER, y1 IN NUMBER,
                x2 IN NUMBER,y2 IN NUMBER , result OUT NOCOPY NUMBER);
end CSF_TDS_PUB;

/
