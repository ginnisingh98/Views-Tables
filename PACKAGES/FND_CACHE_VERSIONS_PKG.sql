--------------------------------------------------------
--  DDL for Package FND_CACHE_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_CACHE_VERSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: AFCCHVRS.pls 120.1 2005/07/02 03:57:50 appldev noship $ */

/*
 * get_values
 *   Use this API to do a bulk collect on FND_CACHE_VERSIONS
 */
procedure get_values;

/*
 * add_cache_name
 *   Use this API to add an entry in FND_CACHE_VERSIONS
 *
 * IN
 *   p_name - name of cache
 *
 */
procedure add_cache_name (p_name varchar2);

/*
 * bump_version
 *   Use this API to increase the version by 1 in FND_CACHE_VERSIONS
 *
 * IN
 *   p_name - name of cache
 *
 */
procedure bump_version (p_name varchar2);

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
	return number;
pragma restrict_references(get_version, WNDS, TRUST);
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
 *                cache is.
 *                If FALSE, retrieve the value from cache since a newer
 *                version exists.
 *
 * RAISES
 *   Never raises exceptions
 */
function check_version (p_name IN varchar2,
                        p_version IN OUT nocopy number)
	return boolean;
pragma restrict_references(check_version, WNDS, TRUST);

end FND_CACHE_VERSIONS_PKG;

 

/
