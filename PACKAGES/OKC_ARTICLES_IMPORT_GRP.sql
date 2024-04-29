--------------------------------------------------------
--  DDL for Package OKC_ARTICLES_IMPORT_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OKC_ARTICLES_IMPORT_GRP" AUTHID CURRENT_USER AS
/* $Header: OKCGAIMS.pls 120.2.12010000.2 2010/04/06 08:59:03 aveeraba ship $ */


  TYPE article_txt_tbl_type is table of OKC_ART_INTERFACE_ALL.ARTICLE_TEXT%TYPE ;


  ---------------------------------------------------------------------------
  -- Procedures and Functions
  ---------------------------------------------------------------------------

  PROCEDURE conc_purge_interface (
    errbuf           OUT NOCOPY VARCHAR2,
    retcode          OUT NOCOPY VARCHAR2,
    p_start_date     IN VARCHAR2,
    p_end_date       IN VARCHAR2,
    p_process_status IN VARCHAR2,
    p_batch_number   IN VARCHAR2);

  PROCEDURE conc_import_articles(
    x_return_status  OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    p_batch_procs_id IN  NUMBER,
    p_batch_number   IN  VARCHAR2,
    p_validate_only  IN  VARCHAR2 := 'Y',
    p_fetchsize      IN  NUMBER  := 100 );


  PROCEDURE import_articles(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100,
    p_rows_processed               OUT NOCOPY NUMBER,
    p_rows_failed                   OUT NOCOPY NUMBER,
    p_rows_warned                 OUT NOCOPY NUMBER
  );

  PROCEDURE import_variables(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100
  );

  PROCEDURE import_relationships(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100,
    p_rows_processed               OUT NOCOPY NUMBER,
    p_rows_failed                   OUT NOCOPY NUMBER,
    p_rows_warned                 OUT NOCOPY NUMBER
  );

  PROCEDURE import_fnd_flex_value_sets(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100
  );

  PROCEDURE import_fnd_flex_values(
    x_return_status                OUT NOCOPY VARCHAR2,
    x_msg_count                    OUT NOCOPY NUMBER,
    x_msg_data                     OUT NOCOPY VARCHAR2,

    p_batch_procs_id               IN NUMBER,
    p_batch_number                 IN VARCHAR2,
    p_validate_only                IN VARCHAR2 := 'Y',
    p_fetchsize                    IN NUMBER := 100
  );

--CLM impact on contracts changes
PROCEDURE import_scn_map(
    x_return_status                OUT NOCOPY VARCHAR2,
    p_batch_number                 IN VARCHAR2,
    p_fetchsize                    IN NUMBER := 100
   );
END OKC_ARTICLES_IMPORT_GRP;

/
