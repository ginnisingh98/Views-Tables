--------------------------------------------------------
--  DDL for Package FA_BALREP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_BALREP_PKG" AUTHID CURRENT_USER AS
/*$Header: fabalreps.pls 120.0.12010000.7 2009/07/30 05:35:47 anujain noship $*/
PROCEDURE LOAD_WORKERS
           (book_type_code     in  varchar2
	   ,request_id         in  number
	   --,batch_size         in  number
	   ,errbuf             out NOCOPY varchar2
	   ,retcode            out NOCOPY number
	   );

Procedure populate_gt_table
     (
      errbuf              IN OUT NOCOPY VARCHAR2
     ,retcode             IN OUT NOCOPY VARCHAR2
     ,Book		  in varchar2
     ,Report_Type	  in	varchar2
     ,Report_Style        in    varchar2
     ,Request_id  	  in	number
     ,Worker_number  	  in	number
     ,Period1_PC          in    number
     ,Period1_POD         in    date
     ,Period1_PCD         in    date
     ,Period2_PC          in    number
     ,Period2_PCD         in    date
     ,Distribution_Source_Book in varchar2
     );

PROCEDURE LAUNCH_WORKERS
      (
        Book         IN VARCHAR2,
	Report_Type  IN VARCHAR2,
	report_style IN VARCHAR2,
	l_Request_id IN NUMBER,
        Period1_PC   IN NUMBER,
	Period1_POD  IN DATE,
	Period1_PCD  IN DATE,
	Period2_PC   IN NUMBER,
	Period2_PCD  IN DATE,
	Distribution_Source_Book  IN VARCHAR2,
	p_total_requests1 IN NUMBER,
	l_errbuf     out NOCOPY varchar2,
	l_retcode    out NOCOPY number
       );
END FA_BALREP_PKG;

/
