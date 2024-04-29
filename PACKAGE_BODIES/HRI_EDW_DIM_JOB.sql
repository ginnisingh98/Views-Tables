--------------------------------------------------------
--  DDL for Package Body HRI_EDW_DIM_JOB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HRI_EDW_DIM_JOB" AS
/* $Header: hriedjob.pkb 115.3 2002/06/10 01:30:48 pkm ship       $ */

/******************************************************************************/
/* This is the function which matches jobs with job category sets.            */
/* If a job has a job category which belongs to the given job category set,   */
/* then the job category name is returned, else the n/a (other) name is       */
/* returned                                                                   */
/******************************************************************************/
FUNCTION find_job_category(p_job_id          IN NUMBER,
                           p_sequence        IN NUMBER)
                           RETURN VARCHAR2 IS

  l_temp           NUMBER := to_number(NULL);  -- Whether a match is found
  l_return_value   VARCHAR2(80) := NULL;       -- Holds the return value

  /* Cursor holding all job categories (codes and lookups) */
  /* associated with the given job */
  CURSOR job_cat_cur IS
  SELECT jei.jei_information1, hrl.meaning
  FROM per_job_extra_info jei,
  hr_lookups hrl
  WHERE jei.job_id = p_job_id
  AND hrl.lookup_type = 'JOB_CATEGORIES'
  AND hrl.lookup_code = jei.jei_information1
  AND information_type = 'Job Category';

  /* Cursor matching job categories with job category sets */
  CURSOR match_set_cur
  (v_job_cat_code   IN VARCHAR2) IS
  SELECT 1 FROM hri_job_category_sets
  WHERE job_category_set = p_sequence
  AND member_lookup_code = v_job_cat_code;

  /* Cursor to get other lookup code */
  CURSOR other_cur IS
  SELECT hrl.meaning
  FROM hri_job_category_sets jsc,
  hr_lookups hrl
  WHERE jsc.job_category_set = p_sequence
  AND jsc.member_lookup_code IS NULL
  AND hrl.lookup_type = 'HRI_JOB_CATEGORY_SETS'
  AND hrl.lookup_code = jsc.other_lookup_code;

BEGIN

/* The following loop goes through all the job categories held against the */
/* given job and compares with the relevant job category set for a match */
/* If matched, the matching lookup is returned */
  FOR job_cat_rec IN job_cat_cur LOOP

  /* Try and find a match */
    OPEN match_set_cur(job_cat_rec.jei_information1);
    FETCH match_set_cur INTO l_temp;
    CLOSE match_set_cur;

  /* Return the first match */
    IF (l_temp = 1) THEN
      RETURN job_cat_rec.meaning;
    END IF;

  END LOOP;

/* If no match found then return the other value */
  OPEN other_cur;
  FETCH other_cur INTO l_return_value;
  CLOSE other_cur;

  RETURN l_return_value;

END find_job_category;


/******************************************************************************/
/* This is a dummy procedure which call the add_job_category procedure in the */
/* business process layer                                                     */
/*                                                                            */
/* HRI Job Categories consists of a number of member (lookups) for the set    */
/* plus one lookup if a job does not match any of the set (other). The single */
/* (other) lookup is identified by the member lookup column holding NULL.     */
/*                                                                            */
/* Add_job_category inserts a row if it does not already exist, but updates   */
/* the other lookup row if it exists already and is different.                */
/******************************************************************************/
PROCEDURE add_job_category( p_job_cat_set     IN NUMBER,
                            p_job_cat_lookup  IN VARCHAR2 := null,
                            p_other_lookup    IN VARCHAR2 := null )
IS

BEGIN
	hri_bpl_job.add_job_category
                          ( p_job_cat_set     => p_job_cat_set
                          , p_job_cat_lookup  => p_job_cat_lookup
                          , p_other_lookup    => p_other_lookup);

END add_job_category;


/******************************************************************************/
/* This is a dummy procedure which calls the remove_job_category procedure    */
/* from the business process layer                                            */
/*                                                                            */
/* Removes given job category by blanket delete                               */
/******************************************************************************/
PROCEDURE remove_job_category( p_job_cat_set     IN NUMBER,
                               p_job_cat_lookup  IN VARCHAR2 := null,
                               p_other_lookup    IN VARCHAR2 := null )
IS

BEGIN
	hri_bpl_job.remove_job_category
		          ( p_job_cat_set     => p_job_cat_set,
                    p_job_cat_lookup  => p_job_cat_lookup,
                    p_other_lookup    => p_other_lookup);

END remove_job_category;


/******************************************************************************/
/* Load row simply calls the update procedure                                 */
/******************************************************************************/
PROCEDURE load_row( p_job_cat_set     IN NUMBER,
                    p_job_cat_lookup  IN VARCHAR2,
                    p_other_lookup    IN VARCHAR2,
                    p_owner           IN VARCHAR2 )
IS

BEGIN

hri_bpl_job.load_row
        ( p_job_cat_set     => p_job_cat_set,
          p_job_cat_lookup  => p_job_cat_lookup,
          p_other_lookup    => p_other_lookup,
          p_owner           => p_owner );

END load_row;

END hri_edw_dim_job;

/
