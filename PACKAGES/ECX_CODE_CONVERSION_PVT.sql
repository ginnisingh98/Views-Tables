--------------------------------------------------------
--  DDL for Package ECX_CODE_CONVERSION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ECX_CODE_CONVERSION_PVT" AUTHID CURRENT_USER AS
-- $Header: ECXXREFS.pls 115.10 2003/02/20 22:33:07 rdiwan ship $

   G_NO_ERRORS                CONSTANT NUMBER         := 0;
   G_INVALID_PARAMETER        CONSTANT NUMBER         := 1;
   G_UNEXP_ERROR              CONSTANT NUMBER         := 2;

   --  Global constants holding the package and file names to be used by
   --  messaging routines in the case of an unexpected error.

   	G_PKG_NAME                 CONSTANT VARCHAR2(30)   := 'ecx_Code_Conversion_PVT';
   	G_FILE_NAME                CONSTANT VARCHAR2(12)   := 'ECXXREFB.pls';

   	G_XREF_NOT_FOUND           CONSTANT VARCHAR2(1)    := 'X';
   	G_RECV_XREF_NOT_FOUND          CONSTANT VARCHAR2(1)    := 'R';

	/** taken from the FND_API for the Standalone Version **/
	G_MISS_NUM      CONSTANT    NUMBER      := 9.99E125;
	G_MISS_CHAR     CONSTANT    VARCHAR2(1) := chr(0);
	G_MISS_DATE     CONSTANT    DATE        := TO_DATE('1','j');

	G_VALID_LEVEL_NONE  CONSTANT    NUMBER := 0;
	G_VALID_LEVEL_FULL  CONSTANT    NUMBER := 100;

	G_RET_STS_SUCCESS       CONSTANT    VARCHAR2(1) :=  'S';
	G_RET_STS_ERROR         CONSTANT    VARCHAR2(1) :=  'E';
	G_RET_STS_UNEXP_ERROR   CONSTANT    VARCHAR2(1) :=  'U';

	G_EXC_ERROR             EXCEPTION;
	G_EXC_UNEXPECTED_ERROR  EXCEPTION;

	G_TRUE      CONSTANT    VARCHAR2(1) := 'T';
	G_FALSE     CONSTANT    VARCHAR2(1) := 'F';

   PROCEDURE populate_plsql_tbl_with_extval(
      p_api_version_number IN             NUMBER,
      p_init_msg_list      IN             VARCHAR2       := G_FALSE,
      p_simulate           IN             VARCHAR2       := G_FALSE,
      p_commit             IN             VARCHAR2       := G_FALSE,
      p_validation_level   IN             NUMBER         := G_VALID_LEVEL_FULL,
      p_standard_id        IN             NUMBER,
      p_return_status      OUT    NOCOPY  VARCHAR2,
      p_msg_count          OUT    NOCOPY  PLS_INTEGER,
      p_msg_data           OUT    NOCOPY  VARCHAR2,
      p_level              IN             PLS_INTEGER,
      p_tbl                IN OUT NOCOPY  ecx_utils.dtd_node_tbl,
      p_tp_id              IN             PLS_INTEGER);

   PROCEDURE populate_plsql_tbl_with_intval(
      p_api_version_number IN             NUMBER,
      p_init_msg_list      IN             VARCHAR2       := G_FALSE,
      p_simulate           IN             VARCHAR2       := G_FALSE,
      p_commit             IN             VARCHAR2       := G_FALSE,
      p_validation_level   IN             NUMBER         := G_VALID_LEVEL_FULL,
      p_standard_id        IN             NUMBER,
      p_return_status      OUT    NOCOPY  VARCHAR2,
      p_msg_count          OUT    NOCOPY  PLS_INTEGER,
      p_msg_data           OUT    NOCOPY  VARCHAR2,
      p_level              IN             PLS_INTEGER,
      p_apps_tbl           IN OUT NOCOPY  ecx_utils.dtd_node_tbl,
      p_tp_id              IN             PLS_INTEGER);

   PROCEDURE convert_external_value(
      p_api_version_number IN             NUMBER,
      p_init_msg_list      IN             VARCHAR2       := G_FALSE,
      p_simulate           IN             VARCHAR2       := G_FALSE,
      p_commit             IN             VARCHAR2       := G_FALSE,
      p_validation_level   IN             NUMBER         := G_VALID_LEVEL_FULL,
      p_standard_id        IN             NUMBER,
      p_return_status      OUT    NOCOPY  VARCHAR2,
      p_msg_count          OUT    NOCOPY  PLS_INTEGER,
      p_msg_data           OUT    NOCOPY  VARCHAR2,
      p_value              IN OUT NOCOPY  VARCHAR2,
      p_category_id        IN             PLS_INTEGER,
      p_snd_tp_id          IN             PLS_INTEGER,
      p_rec_tp_id          IN             PLS_INTEGER);

END;

 

/
