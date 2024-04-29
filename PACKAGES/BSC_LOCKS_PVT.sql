--------------------------------------------------------
--  DDL for Package BSC_LOCKS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_LOCKS_PVT" AUTHID CURRENT_USER AS
/* $Header: BSCVLOKS.pls 120.3 2005/12/07 18:25:34 calaw noship $ */

G_PKG_NAME VARCHAR2(30) := 'BSC_LOCKS_PVT';
TYPE t_array_module IS TABLE OF BSC_LOOKUPS.MEANING%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_object_key IS TABLE OF BSC_OBJECT_LOCKS.OBJECT_KEY%TYPE INDEX BY BINARY_INTEGER;
TYPE t_array_object_type IS TABLE OF BSC_OBJECT_LOCKS.OBJECT_TYPE%TYPE INDEX BY BINARY_INTEGER;
g_modules t_array_module;

/*------------------------------------------------------------------------------------------
Procedure VALIDATE_OBJECT
        This procedure inspects the validity of an Object.
        An exception will be raised if the Object does not exist in the database.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
-------------------------------------------------------------------------------------------*/
Procedure VALIDATE_OBJECT (
          p_object_key          IN             varchar2
         ,p_object_type         IN             varchar2
         ,x_return_status       OUT NOCOPY     varchar2
         ,x_msg_count           OUT NOCOPY     number
         ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Function LOCK_OBJECT
        This function puts a database lock on the corresponding row in the
        lock table and returns the last_save_time value.  If the row does
        not exist, a new row will be inserted to the lock table.
        In addition to that, the user table will also be updated.
        If someone else already locked the object, an exception will be raised.
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Function LOCK_OBJECT(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_query_time          IN             date
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) return DATE;


/*------------------------------------------------------------------------------------------
Procedure LOCK_OBJECT
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
        p_machine: The Machine
        p_terminal: The Terminal
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
-------------------------------------------------------------------------------------------*/
Procedure LOCK_OBJECT(
    p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_query_time          IN             date
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,p_cascade_lock_level  IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Function LOCK_OBJECT_WRITE
        This function acquires a write (exclusive) lock on an Object
        and returns the last_save_time value.
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Function LOCK_OBJECT_WRITE(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) return DATE;


/*------------------------------------------------------------------------------------------
Function LOCK_OBJECT_WRITE
        This function acquires a write (exclusive) lock on an Object
        and returns the last_save_time value.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        x_insert_flag: True if the lock entry is missing in the lock table
-------------------------------------------------------------------------------------------*/
Function LOCK_OBJECT_WRITE(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,x_insert_flag         OUT NOCOPY     boolean
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) return DATE;


/*------------------------------------------------------------------------------------------
Function LOCK_OBJECT_READ
        This procedure acquires puts a read (shared) lock on the Object.
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Function LOCK_OBJECT_READ(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
) return DATE;


/*------------------------------------------------------------------------------------------
Procedure LOCK_OBJECT_ALL
        This procedure locks the locking tables
-------------------------------------------------------------------------------------------*/
Procedure LOCK_OBJECT_ALL(
    x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure LOCK_USER
        This procedure puts a database lock on the corresponding row in the
        lock user table.  If the row does not exist, a new row will be inserted
        to the lock user table.  If someone else already locked the object,
        an exception will be raised.
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure LOCK_USER(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure GET_CHILD_OBJECTS
        This procedure retrieves the list of child objects down the hierarchy
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_cascade_lock_level: Number of level for cascade locks
                              Default is -1 which means enable cascade locking
                              all the way to the lowest level
        p_lowest_level_type: The type of the lowest level object
        x_child_object_keys: Table of child object keys
        x_child_object_types: Table of child object types
        x_child_object_count: Total number of child objects
-------------------------------------------------------------------------------------------*/
Procedure GET_CHILD_OBJECTS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_cascade_lock_level  IN             number
   ,p_lowest_level_type   IN             varchar2
   ,x_child_object_keys   IN OUT NOCOPY  t_array_object_key
   ,x_child_object_types  IN OUT NOCOPY  t_array_object_type
   ,x_child_object_count  IN OUT NOCOPY  number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_ALL
        This procedure inserts the ALL entries into the lock table and user table
  <parameters>
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
        p_machine: The Machine
        p_terminal: The Terminal
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_ALL(
    p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_ALL_AUTONOMOUS
        This procedure inserts the ALL entries into the lock table and user table
  <parameters>
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
        p_machine: The Machine
        p_terminal: The Terminal
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_ALL_AUTONOMOUS(
    p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_SCORECARD
        This procedure inserts scorecard entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_SCORECARD(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_OBJECTIVE
        This procedure inserts objective entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_OBJECTIVE(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_DIMENSION
        This procedure inserts dimension entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_DIMENSION(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_DIMENSION_OBJECT
        This procedure inserts dimension object entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_DIMENSION_OBJECT(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_MEASURE
        This procedure inserts measure entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_MEASURE(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_DATA_COLUMN
        This procedure inserts data column entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_DATA_COLUMN(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_CUSTOM_VIEW
        This procedure inserts custom view entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_CUSTOM_VIEW(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_LAUNCHPAD
        This procedure inserts launchpad entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_LAUNCHPAD(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_PERIODICITY
        This procedure inserts periodicity entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_PERIODICITY(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_CALENDAR
        This procedure inserts calendar entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_CALENDAR(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_TABLE
        This procedure inserts table entries into the lock table and user table
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_TABLE(
    p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_INFO
        This procedure inserts a row in the lock table
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
        p_last_save_time: The last time the Object being modified
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_last_save_time      IN             date
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_LOCK_INFO_AUTONOMOUS
        This procedure inserts a row in the lock table
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
        p_last_save_time: The last time the Object being modified
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure INSERT_LOCK_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_last_save_time      IN             date
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure UPDATE_LOCK_INFO
        This procedure updates the lock table
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
        p_last_save_time: The last time the Object being modified
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure UPDATE_LOCK_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_last_save_time      IN             date
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure UPDATE_LOCK_INFO_AUTONOMOUS
        This procedure updates the lock table
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
        p_last_save_time: The last time the Object being modified
        p_session_id: The Database Session ID
-------------------------------------------------------------------------------------------*/
Procedure UPDATE_LOCK_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_lock_type           IN             varchar2
   ,p_last_save_time      IN             date
   ,p_session_id          IN             number
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_USER_INFO
        This procedure inserts a row into the lock user table
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_USER_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure INSERT_USER_INFO_AUTONOMOUS
        This procedure inserts a row into the lock user table
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure INSERT_USER_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure UPDATE_USER_INFO
        This procedure updates the current user info
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure UPDATE_USER_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure UPDATE_USER_INFO_AUTONOMOUS
        This procedure updates the current user info
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_user_type:  "L" = Lock, "M" = Modify
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure UPDATE_USER_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_user_type           IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure DELETE_LOCK_INFO
        This procedure deletes the lock object
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure DELETE_LOCK_INFO(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure DELETE_LOCK_INFO_AUTONOMOUS
        This procedure deletes the lock object
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
        p_machine: The Machine
        p_terminal: The Terminal
-------------------------------------------------------------------------------------------*/
Procedure DELETE_LOCK_INFO_AUTONOMOUS(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_program_id          IN             number
   ,p_user_id             IN             number
   ,p_machine             IN             varchar2
   ,p_terminal            IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure RAISE_EXCEPTION
        This procedure retrieves the session information and raises an exception
  <parameters>
        p_object_key: The primary key of the Object, usually the TO_CHAR value
                      of the Object ID.  If the Object has composite keys,
                      the value to pass in will be a concatenation of
                      all the keys, separated by commas
        p_object_type: Either "OVERVIEW_PAGE", "SCORECARD", "CUSTOM_VIEW",
                       "LAUNCHPAD", "OBJECTIVE", "MEASURE", "DATA_COLUMN",
                       "DIMENSION", "DIMENSION_OBJECT", "REPORT", "CALENDAR",
                       "PERIODICITY", and "TABLE"
        p_exception_type: "L" = BSC_LOCK_ERR_LOCKED, "M" = BSC_LOCK_ERR_MODIFIED
-------------------------------------------------------------------------------------------*/
Procedure RAISE_EXCEPTION(
    p_object_key          IN             varchar2
   ,p_object_type         IN             varchar2
   ,p_exception_type      IN             varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
Procedure GET_SESSION
        This procedure retrieves the session information (machine, terminal, etc.)
  <parameters>
        x_machine: The machine
        x_terminal: The terminal
-------------------------------------------------------------------------------------------*/
Procedure GET_SESSION(
    x_machine             OUT NOCOPY     varchar2
   ,x_terminal            OUT NOCOPY     varchar2
   ,x_return_status       OUT NOCOPY     varchar2
   ,x_msg_count           OUT NOCOPY     number
   ,x_msg_data            OUT NOCOPY     varchar2
);


/*------------------------------------------------------------------------------------------
  Procedure INITIALIZE

  DESCRIPTION:
     Populate global variables
-------------------------------------------------------------------------------------------*/
Procedure INITIALIZE;


/*------------------------------------------------------------------------------------------
  Function GET_BSC_SCHEMA

  DESCRIPTION:
     Returns the BSC schema name
-------------------------------------------------------------------------------------------*/
Function GET_BSC_SCHEMA
    return VARCHAR2;

/*------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------*/
END  BSC_LOCKS_PVT;

 

/
