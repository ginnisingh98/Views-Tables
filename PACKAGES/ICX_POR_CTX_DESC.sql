--------------------------------------------------------
--  DDL for Package ICX_POR_CTX_DESC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ICX_POR_CTX_DESC" AUTHID CURRENT_USER AS
/* $Header: ICXCGCDS.pls 115.5 2004/03/31 18:44:56 vkartik ship $*/

TYPE item_Source_cv_type IS REF CURSOR;
TYPE CatCurTyp IS REF CURSOR;
BATCH_SIZE       NUMBER:= 5000;

--
-- Cursor to fetch installed languages
--
    CURSOR installed_languages_cur IS
        select language_code
        from fnd_languages
        where installed_flag in ('B', 'I');

PROCEDURE populateCtxDescAll(p_jobno IN INTEGER DEFAULT 0,
                             p_rebuildAll in VARCHAR2 DEFAULT 'Y',
                             p_log_type in VARCHAR2 DEFAULT 'CONCURRENT');
-- Bug # 3441668 : Overloaded version for concurrent request
PROCEDURE populateDescAll(errbuf OUT NOCOPY VARCHAR2,
                          retcode OUT NOCOPY VARCHAR2,
                          p_log_type in VARCHAR2 DEFAULT 'CONCURRENT');
PROCEDURE populateDescAll(p_log_type in VARCHAR2 DEFAULT 'CONCURRENT');
PROCEDURE populateBaseAttributes(pDeleteYN IN VARCHAR2 DEFAULT 'Y',
  pUpdateYN IN VARCHAR2 DEFAULT 'Y', p_log_type IN VARCHAR2 DEFAULT 'LOADER');
PROCEDURE populateCategoryAttribsByJob( pJobNum IN INTEGER DEFAULT 0,
  pDeleteYN IN VARCHAR2 DEFAULT 'Y',
  pUpdateYN IN VARCHAR2 DEFAULT 'Y',
  p_log_type IN VARCHAR2 DEFAULT 'LOADER');
PROCEDURE populateCategoryAttributes( pDeleteYN IN VARCHAR2 DEFAULT 'Y',
  pUpdateYN IN VARCHAR2 DEFAULT 'Y',
  p_log_type IN VARCHAR2 DEFAULT 'LOADER');
PROCEDURE populateCtxDescBaseAtt(pItemSourceCv IN item_source_cv_type,
                                 pDeleteYN IN VARCHAR2 DEFAULT 'Y',
                                 pUpdateYN IN VARCHAR2 DEFAULT 'Y',
                                 pLanguage IN VARCHAR2 DEFAULT NULL,
                                 pSourceType IN VARCHAR2 DEFAULT 'ROWID',
                                 p_log_type IN VARCHAR2 DEFAULT 'LOADER');
PROCEDURE populateCtxDescCatAtt(pCategoryId IN NUMBER,
                                 pItemSourceCursor IN NUMBER,
                                 pDeleteYN IN VARCHAR2 DEFAULT 'Y',
                                 pUpdateYN IN VARCHAR2 DEFAULT 'Y',
                                 pLanguage IN VARCHAR2 DEFAULT NULL,
                                 pSourceType IN VARCHAR2 DEFAULT 'ROWID',
                                 p_log_type IN VARCHAR2 DEFAULT 'LOADER');
PROCEDURE populateCtxDescLang(p_item_id IN NUMBER,
			      p_category_id IN NUMBER,
			      p_lang IN VARCHAR2 DEFAULT NULL,
                              p_log_type IN VARCHAR2 DEFAULT 'LOADER');
PROCEDURE populateBuyerInfo( pDeleteYN IN VARCHAR2 DEFAULT 'Y',
  pUpdateYN IN VARCHAR2 DEFAULT 'Y', p_log_type IN VARCHAR2 default 'LOADER');
PROCEDURE populateCtxDescBuyerInfo(pItemSourceCv IN item_source_cv_type,
                            pDeleteYN IN VARCHAR2 DEFAULT 'Y',
                            pUpdateYN IN VARCHAR2 DEFAULT 'Y',
                            pLanguage IN VARCHAR2 DEFAULT NULL,
                            pSourceType IN VARCHAR2 DEFAULT 'ROWID',
                            p_log_type IN VARCHAR2 DEFAULT 'LOADER');

/*
** Rebuild the search indexes by calling either the context index
** rebuild package or the intermedia package.
*/

PROCEDURE rebuild_indexes;


END ICX_POR_CTX_DESC;

 

/
