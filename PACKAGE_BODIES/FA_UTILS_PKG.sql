--------------------------------------------------------
--  DDL for Package Body FA_UTILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FA_UTILS_PKG" as
/* $Header: FAXUTILB.pls 120.4.12010000.3 2009/07/19 11:12:28 glchen ship $ */

--  Function  faxrnd
--
FUNCTION faxrnd(X_amount   IN OUT NOCOPY NUMBER,
                X_book     IN VARCHAR2,
                X_set_of_books_id IN NUMBER,
                p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                return BOOLEAN is

   l_found            boolean := FALSE;
   l_array_count      number  := faxcurr_table.count;
   l_count            number  := 0;

   BEGIN

     /* look at the record and then the array and if no hit, then select */
     IF (X_set_of_books_id = faxcurr_record.set_of_books_id) then
        null;
     ELSE
        for i in 1..l_array_count loop

            l_count := i;

            if (faxcurr_table(i).set_of_books_id = X_set_of_books_id) then
               l_found := TRUE;
               exit;
            else
               l_found := FALSE;
            end if;

        end loop;

        if l_found = TRUE then
           faxcurr_record       := faxcurr_table(l_count);
        else
           SELECT X_set_of_books_id,
                  curr.currency_code,
                  curr.precision
           INTO   faxcurr_record.set_of_books_id,
                  faxcurr_record.currency_code,
                  faxcurr_record.precision
           FROM   fnd_currencies curr, gl_sets_of_books sob
           WHERE  sob.set_of_books_id = X_set_of_books_id AND
                  curr.currency_code = sob.currency_code;

           faxcurr_table(l_array_count + 1):= faxcurr_record;

        end if;
     END IF;

     X_amount := ROUND(X_amount, faxcurr_record.precision);

     return(TRUE);

   EXCEPTION
     WHEN OTHERS THEN
        if (p_log_level_rec.statement_level) then
           fa_debug_pkg.add('fa_utils_pkg.faxrnd','book', X_book,
              p_log_level_rec => p_log_level_rec);
           fa_debug_pkg.add('fa_utils_pkg.faxceil','set_of_books_id', X_set_of_books_id,
             p_log_level_rec => p_log_level_rec);

        end if;

        FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_UTILS_PKG.faxrnd', p_log_level_rec => p_log_level_rec);
        return(FALSE);

   END faxrnd;


FUNCTION faxtru
	(
	X_num		IN OUT NOCOPY number,
	X_book_type_code 	IN VARCHAR2,
        X_set_of_books_id       IN NUMBER,
	p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
	return boolean is

   l_found            boolean := FALSE;
   l_array_count      number  := faxcurr_table.count;
   l_count            number  := 0;

begin <<FAXTRU>>

     /* look at the record and then the array and if no hit, then select */

     IF (X_set_of_books_id = faxcurr_record.set_of_books_id) then
        null;
     ELSE
        for i in 1..l_array_count loop

            l_count := i;

            if (faxcurr_table(i).set_of_books_id = X_set_of_books_id) then
               l_found := TRUE;
               exit;
            else
               l_found := FALSE;
            end if;

        end loop;

        if l_found = TRUE then
           faxcurr_record       := faxcurr_table(l_count);
        else

           SELECT X_set_of_books_id,
                  curr.precision
           INTO   faxcurr_record.set_of_books_id,
                  faxcurr_record.precision
           FROM   fnd_currencies curr, gl_sets_of_books sob
           WHERE  sob.set_of_books_id = X_set_of_books_id AND
                  curr.currency_code = sob.currency_code;

           faxcurr_table(l_array_count + 1):= faxcurr_record;

        end if;
     END IF;

     --
     -- Truncate in_num based on the precision
     --
     X_num := trunc(X_num, faxcurr_record.precision);

     return (TRUE);

exception
	when others then
                if (p_log_level_rec.statement_level) then
                   fa_debug_pkg.add('fa_utils_pkg.faxtru','book', X_book_type_code,
                      p_log_level_rec => p_log_level_rec);
                   fa_debug_pkg.add('fa_utils_pkg.faxceil','set_of_books_id', X_set_of_books_id,
             p_log_level_rec => p_log_level_rec);

                end if;

		fa_srvr_msg.add_sql_error (
			calling_fn => 'fa_utils_pkg.faxtru', p_log_level_rec => p_log_level_rec);
		return (FALSE);
end FAXTRU;



FUNCTION faxceil(X_amount   IN OUT NOCOPY NUMBER,
                 X_book     IN VARCHAR2,
                 X_set_of_books_id IN NUMBER,
                 p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                 return BOOLEAN is

   l_found            boolean := FALSE;
   l_array_count      number  := faxcurr_table.count;
   l_count            number  := 0;

   BEGIN

     /* look at the record and then the array and if no hit, then select */
     IF (X_set_of_books_id = faxcurr_record.set_of_books_id) then
        null;
     ELSE
        for i in 1..l_array_count loop

            l_count := i;

            if (faxcurr_table(i).set_of_books_id = X_set_of_books_id) then
               l_found := TRUE;
               exit;
            else
               l_found := FALSE;
            end if;

        end loop;

        if l_found = TRUE then
           faxcurr_record       := faxcurr_table(l_count);
        else
           SELECT X_set_of_books_id,
                  curr.currency_code,
                  curr.precision
           INTO   faxcurr_record.set_of_books_id,
                  faxcurr_record.currency_code,
                  faxcurr_record.precision
           FROM   fnd_currencies curr, gl_sets_of_books sob
           WHERE  sob.set_of_books_id = X_set_of_books_id AND
                  curr.currency_code = sob.currency_code;

           faxcurr_table(l_array_count + 1):= faxcurr_record;

        end if;
     END IF;

      X_amount := ceil(X_amount * power(10,faxcurr_record.precision)) /
                 power(10,faxcurr_record.precision);

     return(TRUE);

EXCEPTION
   WHEN OTHERS THEN
      if (p_log_level_rec.statement_level) then
          fa_debug_pkg.add('fa_utils_pkg.faxceil','book', X_book,
             p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('fa_utils_pkg.faxceil','set_of_books_id', X_set_of_books_id,
             p_log_level_rec => p_log_level_rec);
      end if;

      FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_UTILS_PKG.faxceil', p_log_level_rec => p_log_level_rec);
      return(FALSE);

END faxceil;


FUNCTION faxfloor(X_amount   IN OUT NOCOPY NUMBER,
                  X_book     IN VARCHAR2,
                  X_set_of_books_id IN NUMBER,
                  p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                  return BOOLEAN is

   l_found            boolean := FALSE;
   l_array_count      number  := faxcurr_table.count;
   l_count            number  := 0;

   BEGIN

     /* look at the record and then the array and if no hit, then select */
     IF (X_set_of_books_id = faxcurr_record.set_of_books_id) then
        null;
     ELSE
        for i in 1..l_array_count loop

            l_count := i;

            if (faxcurr_table(i).set_of_books_id = X_set_of_books_id) then
               l_found := TRUE;
               exit;
            else
               l_found := FALSE;
            end if;

        end loop;

        if l_found = TRUE then
           faxcurr_record       := faxcurr_table(l_count);
        else
           SELECT X_set_of_books_id,
                  curr.currency_code,
                  curr.precision
           INTO   faxcurr_record.set_of_books_id,
                  faxcurr_record.currency_code,
                  faxcurr_record.precision
           FROM   fnd_currencies curr, gl_sets_of_books sob
           WHERE  sob.set_of_books_id = X_set_of_books_id AND
                  curr.currency_code = sob.currency_code;

           faxcurr_table(l_array_count + 1):= faxcurr_record;

        end if;
     END IF;

     X_amount := trunc(X_amount * power(10,faxcurr_record.precision)) /
                  power(10,faxcurr_record.precision);

     return(TRUE);

EXCEPTION
   WHEN OTHERS THEN
      if (p_log_level_rec.statement_level) then
         fa_debug_pkg.add('fa_utils_pkg.faxfloor','book', X_book,
              p_log_level_rec => p_log_level_rec);
          fa_debug_pkg.add('fa_utils_pkg.faxceil','set_of_books_id', X_set_of_books_id,
             p_log_level_rec => p_log_level_rec);

      end if;

      FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_UTILS_PKG.faxfloor', p_log_level_rec => p_log_level_rec);
      return(FALSE);

END faxfloor;

-- Function faxlkp_meaning()
--
FUNCTION faxlkp_meaning(X_lookup_type   IN  VARCHAR2,
                        X_lookup_code   IN  VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                  return VARCHAR2 is

l_meaning fa_lookups.meaning%TYPE;
l_hash_value NUMBER;

BEGIN
  IF X_lookup_code IS NOT NULL AND
     X_lookup_type IS NOT NULL THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         X_lookup_type||'@*?'||X_lookup_code,
                                         1000,
                                         25000);

    IF faxlkpmg_table.EXISTS(l_hash_value) THEN
        l_meaning := faxlkpmg_table(l_hash_value);
    ELSE
/*modified the following query for bug no.3876060 */
	select 	T.MEANING
	into 	l_meaning
	from 	FA_LOOKUPS_TL T
	where   T.LANGUAGE = USERENV('LANG')
	and 	T.LOOKUP_TYPE = X_lookup_type
	and 	T.LOOKUP_CODE = X_lookup_code;

      faxlkpmg_table(l_hash_value) := l_meaning;

    END IF;

  END IF;

  return(l_meaning);

EXCEPTION
   WHEN no_data_found THEN
      return(null);
   WHEN OTHERS THEN
      FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_UTILS_PKG.faxlkp_meaning', p_log_level_rec => p_log_level_rec);
      raise;

END faxlkp_meaning;

FUNCTION faxlkp_code(X_lookup_type   IN  VARCHAR2,
                     X_meaning       IN  VARCHAR2, p_log_level_rec        IN     FA_API_TYPES.log_level_rec_type default null)
                  return VARCHAR2 is

l_lookup_code fa_lookups.Lookup_code%TYPE;
l_hash_value NUMBER;

BEGIN
 IF X_Meaning IS NOT NULL AND
    X_lookup_type IS NOT NULL THEN

    l_hash_value := DBMS_UTILITY.get_hash_value(
                                         X_lookup_type||'@*?'||X_meaning,
                                         1000,
                                         25000);
    IF faxlkpcd_table.EXISTS(l_hash_value) THEN
        l_lookup_code := faxlkpcd_table(l_hash_value);
    ELSE
/* modified the following query for bug no.3876060 */
	SELECT  T.LOOKUP_CODE
	into 	l_lookup_code
	FROM 	FA_LOOKUPS_TL T
	WHERE   T.LANGUAGE = USERENV('LANG')
	AND 	T.LOOKUP_TYPE = X_lookup_type
	AND 	T.MEANING = X_meaning;

        faxlkpcd_table(l_hash_value) := l_lookup_code;

     END IF;
  END IF;

   return(l_lookup_code);

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      return(null);
   WHEN OTHERS THEN
      FA_SRVR_MSG.ADD_SQL_ERROR(CALLING_FN => 'FA_UTILS_PKG.faxlkp_code', p_log_level_rec => p_log_level_rec);
      raise;

END faxlkp_code;

END FA_UTILS_PKG;

/
