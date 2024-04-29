--------------------------------------------------------
--  DDL for Package Body FND_CACHE_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_CACHE_VERSIONS_PKG" as
/* $Header: AFCCHVRB.pls 120.4 2006/10/27 17:01:17 pdeluna noship $ */


/* Arrays for bulk collects */
TYPE NameTab IS TABLE OF FND_CACHE_VERSIONS.NAME%TYPE;
TYPE VersTab IS TABLE OF FND_CACHE_VERSIONS.VERSION%TYPE;
cacheName NameTab;
cacheVersion VersTab;

/*
 * get_values
 *   Use this API to do a bulk collect on FND_CACHE_VERSIONS
 */
procedure get_values is
begin
   select NAME, VERSION
   bulk collect into cacheName, cacheVersion
   from FND_CACHE_VERSIONS;
end;

/*
 * add_cache_name
 *   Use this API to add an entry in FND_CACHE_VERSIONS
 *
 * IN
 *   p_name - name of cache
 *
 */
procedure add_cache_name (p_name varchar2)
   is
begin

   -- Add a record into FND_CACHE_VERSIONS
   insert into FND_CACHE_VERSIONS(
      NAME,
      VERSION
   ) values (
      p_name,
      0);

   get_values; -- Refresh the arrays.

end;

/*
 * bump_version
 *   Use this API to increase the version by 1 in FND_CACHE_VERSIONS
 *
 * IN
 *   p_name - name of cache
 *
 */
procedure bump_version (p_name varchar2)
   is
begin

    -- Try to update FND_CACHE_VERSIONS given the name.
   update FND_CACHE_VERSIONS
   set VERSION = VERSION + 1
   where NAME = p_name;

   -- If name does not exist, insert the name using add_version.
   if (sql%rowcount = 0) then
      add_cache_name(p_name);
   else
      get_values; -- Refresh the arrays.
   end if;

end;

/*
 * get_version
 *   Use this API to get the current version in FND_CACHE_VERSIONS
 *
 * IN
 *   p_name - name of cache
 *
 * RETURN
 *   returns the current_version in FND_CACHE_VERSIONS given a name
 *
 * RAISES
 *   Never raises exceptions, returns -1 if name does not exist
 */
function get_version (p_name varchar2)
   return number
is
   current_version   number := -1; -- Bug 5629463:get_version returns NULL
begin

   if cacheName is null then
      get_values;

      -- Please note that the previous fix to bug 4308360 has been moved
      -- outside of this conditional block due to bug 5161071.

      /* For bug 4308360. When there is no data, bulk collect option is
       * not returning 'when_no_data_found' exception and the values for
       * cachName.FIRST, cacheName.LAST are NULL, and this
       * raises ORA-6502 exception at 'for i in cacheName.FIRST' line.
       * Hence the following IF block is written.
       *
      if (cacheName.COUNT = 0) then
         return -1;
      end if;
      */
   end if;

   /* Bug 5161071:4308360: ORA-06502 FND_CACHE_VERSIONS_PKG.get_version
    * The previous fix for bug 4308360 did not completely resolve the issue
    * since it was placed in a conditional block.  As it happens, the
    * condition is not satisfied in all cases and the failover is bypassed
    * causing the ORA-6502 error to be raised.
    *
    * This, hopefully, more complete fix is to move the failover outside of
    * the conditional block.  This should catch all cases that the failover
    * would be required.
    */

   -- Bug 5161071 shows a case where the 'cacheName is null' condition is not
   -- met while FND_CACHE_VERSIONS table is empty.  Hence, the
   -- cacheName.COUNT = 0 condition should prevent the ORA-6502 error that
   -- gets raised when the for loop executes even when cacheName.COUNT = 0.
   if (cacheName.COUNT = 0) then
      return -1;
   else
      for i in cacheName.FIRST..cacheName.LAST loop
         if cacheName(i) = p_name then
            current_version := cacheVersion(i);
         end if;
      end loop;
   end if;

   return current_version;
exception
   when no_data_found then
      return -1;
end;
/*
 * check_version
 *   Use this API to get the current version in FND_CACHE_VERSIONS
 *
 * IN
 *   p_name - name of cache
 *
 * IN/OUT
 *   p_version - version, can be updated with current_version if applicable.
 *               If p_version is updated with current_version, then the RETURN
 *               value of the function is FALSE and the p_version value
 *               returned can be used to obtain the new value from cache.
 *
 * RETURN
 *   TRUE/FALSE - If TRUE, no need to retrieve value from cache (wherever
 *                cache is).
 *                If FALSE, retrieve the value from cache since a newer
 *                version exists.
 *
 * RAISES
 *   Never raises exceptions
 */
function check_version (p_name IN varchar2,
                        p_version IN OUT nocopy number)
   return boolean
is
   current_version number;
begin
   -- Get the current version for the cache name provided.
   current_version := get_version(p_name);

   -- If -1 is returned, then the cache_name does not exist yet.  Still, set version to
   -- current_version and return FALSE.  This will be used as a flag to inidcate that the
   -- cache_name does not exist yet.
   if (current_version = -1) then
      p_version := current_version;
      return FALSE;

   -- If version is less than current version, then set version to current
   -- version and set flag to FALSE.
   elsif (p_version < current_version) then
      p_version := current_version;
      return FALSE;

   -- If version is greater than current version (which should NEVER
   -- happen), then set an error message to the stack and return FALSE;
   -- **FND_VERSION_GREATER_THAN_CURR message is to be created**.
   elsif (p_version > current_version) then
      fnd_message.set_name('FND', 'FND_VERSION_GREATER_THAN_CURR');
      fnd_message.set_token('CACHE_NAME', p_name);
      RETURN FALSE;

   end if;

   return TRUE;

end;

end FND_CACHE_VERSIONS_PKG;

/
