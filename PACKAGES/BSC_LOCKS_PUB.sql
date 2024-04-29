--------------------------------------------------------
--  DDL for Package BSC_LOCKS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_LOCKS_PUB" AUTHID CURRENT_USER AS
/* $Header: BSCPLOKS.pls 120.3 2005/09/19 18:00:43 calaw noship $ */

G_PKG_NAME VARCHAR2(30) := 'BSC_LOCKS_PUB';
--TYPE T_ARRAY_OF_LOCK_OBJECT_KEY IS TABLE OF VARCHAR2(500);
--TYPE T_ARRAY_OF_LOCK_OBJECT_TYPE IS TABLE OF VARCHAR2(50);

/*------------------------------------------------------------------------------------------
Procedure CHECK_SYSTEM_LOCK
        This procedure is called when users enter a UI flow.  It verifies that the
        Object being modified is not locked.  If the Object is locked, some other user
        is currently in the process of saving his changes to the database.
        As a result, the value retrieved from the database is still the old value.
        An error will be raised to indicate that the user has to wait until
        the save is completed.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  CHECK_SYSTEM_LOCK (
          p_object_key          IN             varchar2
         ,p_object_type         IN             varchar2
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure CHECK_SYSTEM_LOCKS
        This procedure is called when users enter a UI flow.  It verifies that the
        Objects being modified are not locked.  If any of the Objects is locked,
        some other user is currently in the process of saving his changes to the database.
        As a result, the value retrieved from the database is still the old value.
        An error will be raised to indicate that the user has to wait until
        the save is completed.
  <parameters>
        p_object_keys: The primary key of the Objects, usually the TO_CHAR value
                       of the Object ID.  If the Object has composite keys,
                       the value to pass in will be a concatenation of
                       all the keys, separated by commas
        p_object_types: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                        "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                        "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                        "PERIODICITY", and "TABLE"
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  CHECK_SYSTEM_LOCKS (
          p_object_keys         IN             BSC_LOCK_OBJECT_KEY_LIST
         ,p_object_types        IN             BSC_LOCK_OBJECT_TYPE_LIST
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Function GET_SYSTEM_TIME
        This function returns the current database system date.
        The system date will be cached by the calling module as the "Query Time",
        which will be used by BSC_LOCKS_PUB.Get_System_Lock to determine
        if a lock can be acquired on an Object.
  <parameters>
        none
-------------------------------------------------------------------------------------------*/
Function  GET_SYSTEM_TIME
  return DATE;


/*------------------------------------------------------------------------------------------
Procedure SYNCHRONIZE
        This procedure removes the invalid and deleted Objects from the locking tables
        When we delete an Object or update the key value of an Object,
        the entries in the lock tables remain there.  After some time,
        more and more invalid rows will be in the lock tables.
        This SYNCHRONIZE api cleans up the lock tables and synchronizes the data
        with the latest metadata.  It will be called by the Generate Database
        concurrent request after the generation process has completed.
  <parameters>
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
-------------------------------------------------------------------------------------------*/
Procedure  SYNCHRONIZE (
          p_program_id          IN             number
         ,p_user_id             IN             number
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCK
        This procedure replaces the existing API BSC_SECURITY.Check_System_Lock
        to be the locking procedure for BSC modules.  Instead of calling the API
        at the start of the process flow, this new API will be called right
        before the changes are committed to the database.

        Passing in the key and type of the top-level object, this API will
        figure out all the related objects that needed to be locked.
        If the locks cannot be acquired, either because some other users
        are possessing one of more of the required locks or the data
        has been modified since the last query time, an exception will be raised
        indicating that the user has to requery and re-do the changes.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_lock_type: 'W' for write lock, 'R' for read lock
        p_query_time: The query time at the start of the process flow
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  GET_SYSTEM_LOCK (
          p_object_key          IN             varchar2
         ,p_object_type         IN             varchar2
         ,p_lock_type           IN             varchar2 := 'W'
         ,p_query_time          IN             date
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCKS
        This procedure replaces the existing API BSC_SECURITY.Check_System_Lock
        to be the locking procedure for BSC modules.  Instead of calling the API
        at the start of the process flow, this new API will be called right
        before the changes are committed to the database.

        Passing in the keys and types of the top-level objects, this API will
        figure out all the related objects that needed to be locked.
        If the locks cannot be acquired, either because some other users
        are possessing one of more of the required locks or the data
        has been modified since the last query time, an exception will be raised
        indicating that the user has to requery and re-do the changes.
  <parameters>
        p_object_keys: The primary key of the Objects, usually the TO_CHAR value
                       of the Object IDs.  If the Object has composite keys,
                       the value to pass in will be a concatenation of
                       all the keys, separated by commas
        p_object_types: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                        "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                        "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                        "PERIODICITY", and "TABLE"
        p_lock_type: 'W' for write lock, 'R' for read lock
        p_query_time: The query time at the start of the process flow
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  GET_SYSTEM_LOCKS (
          p_object_keys         IN             BSC_LOCK_OBJECT_KEY_LIST
         ,p_object_types        IN             BSC_LOCK_OBJECT_TYPE_LIST
         ,p_lock_type           IN             varchar2 := 'W'
         ,p_query_time          IN             date
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCKS
        This procedure replaces the existing API BSC_SECURITY.Check_System_Lock
        to be the locking procedure for BSC modules.  Instead of calling the API
        at the start of the process flow, this new API will be called right
        before the changes are committed to the database.

        Passing in the keys and types of the top-level objects, this API will
        figure out all the related objects that needed to be locked.
        If the locks cannot be acquired, either because some other users
        are possessing one of more of the required locks or the data
        has been modified since the last query time, an exception will be raised
        indicating that the user has to requery and re-do the changes.
  <parameters>
        p_object_keys: The primary key of the Objects, usually the TO_CHAR value
                       of the Object IDs.  If the Object has composite keys,
                       the value to pass in will be a concatenation of
                       all the keys, separated by commas
        p_object_types: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                        "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                        "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                        "PERIODICITY", and "TABLE"
        p_lock_types: 'W' for write lock, 'R' for read lock
        p_query_time: The query time at the start of the process flow
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  GET_SYSTEM_LOCKS (
          p_object_keys         IN             BSC_LOCK_OBJECT_KEY_LIST
         ,p_object_types        IN             BSC_LOCK_OBJECT_TYPE_LIST
         ,p_lock_types          IN             BSC_LOCK_LOCK_TYPE_LIST
         ,p_query_time          IN             date
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCK
        This procedure locks all the objects with a certain type
  <parameters>
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_lock_type: 'W' for write lock, 'R' for read lock
        p_query_time: The query time at the start of the process flow
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure  GET_SYSTEM_LOCK (
          p_object_type         IN             varchar2
         ,p_lock_type           IN             varchar2 := 'W'
         ,p_query_time          IN             date
         ,p_program_id          IN             number
         ,p_user_id             IN             number   := NULL
         ,p_cascade_lock_level  IN             number   := -1
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEN_LOCK
        This procedure locks the whole table.  This feature is used in Migration.
  <parameters>
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
-------------------------------------------------------------------------------------------*/
Procedure  GET_SYSTEM_LOCK (
          p_program_id          IN             number
         ,p_user_id             IN             number
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure GET_SYSTEM_LOCK
        Due to the fact that not all the BSC modules will uptake the new locking scheme
        immediately, we will temporaily keep populating the BSC_CURRENT_SESSIONS table
        for backward compatibility issues.  In this procedure, we will check for whole
        system exclusive locks acquired by modules that haven't uptaken the new
        locking scheme.  Only when none of these modules have acquired locks that
        the new Object-Level locking will be proceeded.  Next, a row will be inserted
        into BSC_CURRENT_SESSIONS.  It will be seen as a whole system exclusive lock by
        modules haven't implemented the new locking scheme.  For modules that have uptaken
        the new locking scheme, those entries in BSC_CURRENT_SESSION will be ignored.
  <parameters>
        p_program_id: -100 = Data Loader UI
                      -101 = Data Loader Backend
                      -200 = Generate Database
                      -201 = Generate Documentation
                      -202 = Rename Interface Table
                      -203 = Generate Database Configuration
                      -300 = Administrator
                      -400 = Objective Designer
                      -500 = Builder
                      -600 = Performance Scorecard
                      -700 = System Upgrade
                      -800 = System Migration
        p_user_id: Application User ID
        p_icx_session_id: Application Session ID
-------------------------------------------------------------------------------------------*/
Procedure  GET_SYSTEM_LOCK (
          p_program_id          IN             number
         ,p_user_id             IN             number
         ,p_icx_session_id      IN             number
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure REMOVE_SYSTEM_LOCK
        Due to the fact that not all the BSC modules will uptake the new locking scheme
        immediately, we will temporaily keep populating the BSC_CURRENT_SESSIONS table
        for backward compatibility issues.  This procedure will be called at the end
        of the process.  The entry in BSC_CURRENT_SESSIONS for the current session
        will be deleted
  <parameters>
        none
-------------------------------------------------------------------------------------------*/
Procedure  REMOVE_SYSTEM_LOCK;

/*------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------*/
END  BSC_LOCKS_PUB;
 

/
