--------------------------------------------------------
--  DDL for Package Body FA_FLEX_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_FLEX_PVT" as
/* $Header: FAVFLEXB.pls 120.3.12010000.2 2009/07/19 11:30:31 glchen ship $   */

FUNCTION get_concat_segs
   (p_ccid                   IN  number,
    p_application_short_name IN  varchar,
    p_flex_code              IN  varchar,
    p_flex_num               IN  number,
    p_num_segs               OUT NOCOPY number,
    p_delimiter              OUT NOCOPY varchar,
    p_segment_array          OUT NOCOPY FND_FLEX_EXT.SEGMENTARRAY,
    p_concat_string          OUT NOCOPY varchar
    , p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type) RETURN BOOLEAN IS

   l_num           number := 1;
   error_found     exception;

BEGIN

   -- initialize
   p_concat_string := '';

   IF (NOT FND_FLEX_EXT.GET_SEGMENTS(p_application_short_name,
                                     p_flex_code,
                                     p_flex_num,
                                     p_ccid,
                                     p_num_segs,
                                     p_segment_array)) THEN
       RAISE error_found;
   END IF;

   p_delimiter := FND_FLEX_EXT.get_delimiter(
                                     p_application_short_name,
                                     p_flex_code,
                                     p_flex_num);

   if (p_delimiter is null) then
       RAISE error_found;
   end if;

   -- fill the string for messaging with concat segs...

   while (l_num <= p_num_segs) loop

      if (l_num > 1) then
          p_concat_string := p_concat_string || p_delimiter;
      end if;

      p_concat_string := p_concat_string || p_segment_array(l_num);

      l_num := l_num + 1;

   end loop;

   return true;

EXCEPTION
  when error_found then
     fa_srvr_msg.add_message(calling_fn => 'fa_flex_pvt.get_concat_segs',  p_log_level_rec => p_log_level_rec);
     return false;

  when others then
     fa_srvr_msg.add_sql_error(calling_fn => 'fa_flex_pvt.get_concat_segs',  p_log_level_rec => p_log_level_rec);
     return false;

END get_concat_segs;


END FA_FLEX_PVT;

/
