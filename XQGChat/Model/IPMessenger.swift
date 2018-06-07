//
//  IPMessenger.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/5/29.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import Foundation
/*  IP Messenger Communication Protocol version 3.0 define  */
func GET_MODE(command: UInt32) -> Int {
    return Int(command & 0x000000ff)
}
func GET_OPT(command: UInt32) -> Int {
    return Int(command & 0xffffff00)
}
/*  header  */
let IPMSG_VERSION           = 0x0001
let IPMSG_DEFAULT_PORT      = 0x0979
/*  command  */
let IPMSG_NOOPERATION       = 0x00000000
let IPMSG_BR_ENTRY          = 0x00000001
let IPMSG_BR_EXIT           = 0x00000002
let IPMSG_ANSENTRY          = 0x00000003
let IPMSG_BR_ABSENCE        = 0x00000004
let IPMSG_BR_ISGETLIST      = 0x00000010
let IPMSG_OKGETLIST         = 0x00000011
let IPMSG_GETLIST           = 0x00000012
let IPMSG_ANSLIST           = 0x00000013
let IPMSG_BR_ISGETLIST2     = 0x00000018
let IPMSG_SENDMSG           = 0x00000020
let IPMSG_RECVMSG           = 0x00000021
let IPMSG_READMSG           = 0x00000030
let IPMSG_DELMSG            = 0x00000031
let IPMSG_ANSREADMSG        = 0x00000032
let IPMSG_GETINFO           = 0x00000040
let IPMSG_SENDINFO          = 0x00000041
let IPMSG_GETABSENCEINFO    = 0x00000050
let IPMSG_SENDABSENCEINFO   = 0x00000051

let IPMSG_GETFILEDATA       = 0x00000060
let IPMSG_RELEASEFILES      = 0x00000061
let IPMSG_GETDIRFILES       = 0x00000062
let IPMSG_GETPUBKEY         = 0x00000072
let IPMSG_ANSPUBKEY         = 0x00000073
/*  option for all command  */
let IPMSG_ABSENCEOPT        = 0x00000100
let IPMSG_SERVEROPT         = 0x00000200
let IPMSG_DIALUPOPT         = 0x00010000
let IPMSG_FILEATTACHOPT     = 0x00200000
let IPMSG_ENCRYPTOPT        = 0x00400000
let IPMSG_UTF8OPT           = 0x00800000
let IPMSG_CAPUTF8OPT        = 0x01000000
let IPMSG_ENCEXTMSGOPT      = 0x04000000
let IPMSG_CLIPBOARDOPT      = 0x08000000
/*  option for send command  */
let IPMSG_SENDCHECKOPT      = 0x00000100
let IPMSG_SECRETOPT         = 0x00000200
let IPMSG_BROADCASTOPT      = 0x00000400
let IPMSG_MULTICASTOPT      = 0x00000800
let IPMSG_AUTORETOPT        = 0x00002000
let IPMSG_RETRYOPT          = 0x00004000
let IPMSG_PASSWORDOPT       = 0x00008000
let IPMSG_NOLOGOPT          = 0x00020000
let IPMSG_NOADDLISTOPT      = 0x00080000
let IPMSG_READCHECKOPT      = 0x00100000
let IPMSG_SECRETEXOPT       = IPMSG_READCHECKOPT | IPMSG_SECRETOPT
/*  obsolete option for send command  */
let IPMSG_NOPOPUPOPTOBSOLT  = 0x00001000
let IPMSG_NEWMULTIOPTOBSOLT = 0x00040000
/* encryption/capability flags for encrypt command */
let IPMSG_RSA_512           = 0x00000001
let IPMSG_RSA_1024          = 0x00000002
let IPMSG_RSA_2048          = 0x00000004
let IPMSG_RC2_40            = 0x00001000
let IPMSG_BLOWFISH_128      = 0x00020000
let IPMSG_AES_256           = 0x00100000
let IPMSG_PACKETNO_IV       = 0x00800000
let IPMSG_ENCODE_BASE64     = 0x01000000
let IPMSG_SIGN_SHA1         = 0x20000000
/* compatibilty for Win beta version */
let IPMSG_RC2_40OLD         = 0x00000010
let IPMSG_RC2_128OLD        = 0x00000040
let IPMSG_BLOWFISH_128OLD   = 0x00000400
let IPMSG_RC2_128OBSOLETE   = 0x00004000
let IPMSG_RC2_256OBSOLETE   = 0x00008000
let IPMSG_BLOWFISH_256OBSOL = 0x00040000
let IPMSG_AES_128OBSOLETE   = 0x00080000
let IPMSG_SIGN_MD5OBSOLETE  = 0x10000000
let IPMSG_UNAMEEXTOPTOBSOLT = 0x02000000
/* file types for fileattach command */
let IPMSG_FILE_REGULAR      = 0x00000001
let IPMSG_FILE_DIR          = 0x00000002
let IPMSG_FILE_RETPARENT    = 0x00000003
let IPMSG_FILE_SYMLINK      = 0x00000004
let IPMSG_FILE_CDEV         = 0x00000005
let IPMSG_FILE_BDEV         = 0x00000006
let IPMSG_FILE_FIFO         = 0x00000007
let IPMSG_FILE_RESFORK      = 0x00000010
let IPMSG_FILE_CLIPBOARD    = 0x00000020
/* file attribute options for fileattach command */
let IPMSG_FILE_RONLYOPT     = 0x00000100
let IPMSG_FILE_HIDDENOPT    = 0x00001000
let IPMSG_FILE_EXHIDDENOPT  = 0x00002000
let IPMSG_FILE_ARCHIVEOPT   = 0x00004000
let IPMSG_FILE_SYSTEMOPT    = 0x00008000
/* extend attribute types for fileattach command */
let IPMSG_FILE_UID          = 0x00000001
let IPMSG_FILE_USERNAME     = 0x00000002
let IPMSG_FILE_GID          = 0x00000003
let IPMSG_FILE_GROUPNAME    = 0x00000004
let IPMSG_FILE_CLIPBOARDPOS = 0x00000008
let IPMSG_FILE_PERM         = 0x00000010
let IPMSG_FILE_MAJORNO      = 0x00000011
let IPMSG_FILE_MINORNO      = 0x00000012
let IPMSG_FILE_CTIME        = 0x00000013
let IPMSG_FILE_MTIME        = 0x00000014
let IPMSG_FILE_ATIME        = 0x00000015
let IPMSG_FILE_CREATETIME   = 0x00000016
let IPMSG_FILE_CREATOR      = 0x00000020
let IPMSG_FILE_FILETYPE     = 0x00000021
let IPMSG_FILE_FINDERINFO   = 0x00000022
let IPMSG_FILE_ACL          = 0x00000030
let IPMSG_FILE_ALIASFNAME   = 0x00000040

//let FILELIST_SEPARATOR   = '\a'
//let HOSTLIST_SEPARATOR   = '\a'
//let HOSTLIST_DUMMY       = "\b"

//#define FILELIST_SEPARATOR '\a'
//#define HOSTLIST_SEPARATOR '\a'
//let HOSTLIST_DUMMY = "\b"
/*  end of IP Messenger Communication Protocol version 3.0 define  */
/*============================================================================*
 * IP Messenger for Mac OS X 定数定義
 *============================================================================*/
let MESSAGE_SEPARATOR       = ":"
let MAX_SOCKBUF             = 32768
