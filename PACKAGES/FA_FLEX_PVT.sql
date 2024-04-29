--------------------------------------------------------
--  DDL for Package FA_FLEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_FLEX_PVT" AUTHID CURRENT_USER as
/* $Header: FAVFLEXS.pls 120.2.12010000.2 2009/07/19 11:31:01 glchen ship $   */


FUNCTION get_concat_segs
    (p_ccid                   IN  number,
     p_application_short_name IN  varchar,
     p_flex_code              IN  varchar,
     p_flex_num               IN  number,
     p_num_segs               OUT NOCOPY number,
     p_delimiter              OUT NOCOPY varchar,
     p_segment_array          OUT NOCOPY FND_FLEX_EXT.SEGMENTARRAY,
     p_concat_string          OUT NOCOPY varchar
     , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN;

END FA_FLEX_PVT;

/
