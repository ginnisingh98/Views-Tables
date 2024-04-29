--------------------------------------------------------
--  DDL for Package PER_IMAGE_UPLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_IMAGE_UPLOAD_PKG" AUTHID CURRENT_USER as
/* $Header: peimgupl.pkh 115.9 2004/02/11 01:42:59 sxshah ship $ */

--
-- LOAD
--

    procedure Load( doc       in varchar2,
                    access_id in number ) ;

--
-- LAUNCH
--
    procedure Launch;

-- Copy FND_LOBS.FILE_DATA to PER_IMAGES.IMAGE using the given PKs
--
-- TRANSFER
--
-- Now using error message processing in peimgupl.pkb
--
    function Transfer (file_id       in number,
                       image_id      in number,
                       connectString in varchar2,
                       un            in varchar2,
                       pw            in varchar2,
                       msg           in out nocopy varchar2) return int;

--
-- IMAGE_IS_BLOB
-- Returns TRUE if the datatype of column PER_IMAGES.IMAGE is BLOB, FALSE
-- otherwise.
function image_is_blob return boolean;

end PER_IMAGE_UPLOAD_PKG;

 

/
