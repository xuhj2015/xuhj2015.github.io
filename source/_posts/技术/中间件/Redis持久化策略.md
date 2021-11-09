---
title: Redis持久化策略
date: 2021-11-09
tags: [中间件-Redis]
categories: [计算机技术]
---


Redis提供两种方式进行持久化，RDB(redis database)和AOF(append only file)。

# RDB
RDB持久化是指在指定的时间间隔内将内存中的数据集快照写入磁盘，实际操作过程是fork一个子进程，先将数据集写入临时文件，写入成功后，再替换之前的文件，用二进制压缩存储。

Redis会将数据集的快照dump到dump.rdb文件中。此外，也可以通过配置文件来修改Redis服务器dump快照的频率，在配置文件中可以看到下面的配置信息：
save 900 1           #在900秒(15分钟)之后，如果至少有1个key发生变化，则dump内存快照。
save 300 10          #在300秒(5分钟)之后，如果至少有10个key发生变化，则dump内存快照。
save 60 10000        #在60秒(1分钟)之后，如果至少有10000个key发生变化，则dump内存快照。


# AOF
AOF是类似于log的机制，每次写操作都会将记录写到硬盘上，当系统崩溃时，可以通过AOF来恢复数据。每个带有写操作的命令被Redis服务器端收到运行时，该命令都会被记录到AOF文件上。由于只是一个append到文件操作，所以写到硬盘上的操作往往非常快。

AOF在Redis的配置文件中存在三种同步方式，它们分别是：
appendfsync always     #每次有数据修改发生时都会写入AOF文件。
appendfsync everysec   #每秒钟同步一次，该策略为AOF的缺省策略。
appendfsync no         #从不同步。高效但是数据不会被持久化。

由于AOF对日志文件的写入操作采用的是append模式，因此在写入过程中即使出现宕机现象，也不会破坏日志文件中已经存在的内容。然而如果本次操作只是写入了一半数据就出现了系统崩溃问题，那么在Redis下一次启动之前，可以通过redis-check-aof工具来解决数据一致性的问题。

AOF实际上包含了AOF和rewrite。当AOF文件随着写命令的运行膨胀时，当文件大小触碰到临界时，rewrite会被运行。rewrite会像replication一样，fork出一个子进程，创建一个临时文件，遍历数据库，将每个key、value对输出到临时文件。输出格式就是Redis的命令，但是为了减小文件大小，会将多个key、value对集合起来用一条命令表达。在rewrite期间的写操作会保存在内存的rewrite buffer中，rewrite成功后这些操作也会复制到临时文件中，在最后临时文件会代替AOF文件。

rewrite操作除了有AOF触发之外，还可以通过bgrewriteaof命令调用。

auto_aofrewrite_perc: aof文件的大小超过基准百分之多少后触发bgrewriteaof。默认这个值设置为100，意味着当前aof是基准大小的两倍的时候触发bgrewriteaof。把它设置为0可以禁用自动触发的功能。
auto_aofrewrite_min_size: 当前aof文件大于多少字节后才触发。避免在aof较小的时候无谓行为。默认大小为64mb。

手动触发的bgrewriteaof的时候如果同时存在bgsave在备份，会推迟这次操做的事件，设置server.aofrewrite_scheduled=1，待到bgsave结束后的下一次serverCron里才会触发。