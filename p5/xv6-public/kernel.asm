
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc f0 b5 51 80       	mov    $0x8051b5f0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 70 30 10 80       	mov    $0x80103070,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax
80100034:	66 90                	xchg   %ax,%ax
80100036:	66 90                	xchg   %ax,%ax
80100038:	66 90                	xchg   %ax,%ax
8010003a:	66 90                	xchg   %ax,%ax
8010003c:	66 90                	xchg   %ax,%ax
8010003e:	66 90                	xchg   %ax,%ax

80100040 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100040:	55                   	push   %ebp
80100041:	89 e5                	mov    %esp,%ebp
80100043:	53                   	push   %ebx

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100044:	bb 54 b5 10 80       	mov    $0x8010b554,%ebx
{
80100049:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
8010004c:	68 a0 7b 10 80       	push   $0x80107ba0
80100051:	68 20 b5 10 80       	push   $0x8010b520
80100056:	e8 45 49 00 00       	call   801049a0 <initlock>
  bcache.head.next = &bcache.head;
8010005b:	83 c4 10             	add    $0x10,%esp
8010005e:	b8 1c fc 10 80       	mov    $0x8010fc1c,%eax
  bcache.head.prev = &bcache.head;
80100063:	c7 05 6c fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc6c
8010006a:	fc 10 80 
  bcache.head.next = &bcache.head;
8010006d:	c7 05 70 fc 10 80 1c 	movl   $0x8010fc1c,0x8010fc70
80100074:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100077:	eb 09                	jmp    80100082 <binit+0x42>
80100079:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100080:	89 d3                	mov    %edx,%ebx
    b->next = bcache.head.next;
80100082:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
    initsleeplock(&b->lock, "buffer");
80100085:	83 ec 08             	sub    $0x8,%esp
80100088:	8d 43 0c             	lea    0xc(%ebx),%eax
    b->prev = &bcache.head;
8010008b:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100092:	68 a7 7b 10 80       	push   $0x80107ba7
80100097:	50                   	push   %eax
80100098:	e8 d3 47 00 00       	call   80104870 <initsleeplock>
    bcache.head.next->prev = b;
8010009d:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000a2:	8d 93 5c 02 00 00    	lea    0x25c(%ebx),%edx
801000a8:	83 c4 10             	add    $0x10,%esp
    bcache.head.next->prev = b;
801000ab:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
801000ae:	89 d8                	mov    %ebx,%eax
801000b0:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
801000b6:	81 fb c0 f9 10 80    	cmp    $0x8010f9c0,%ebx
801000bc:	75 c2                	jne    80100080 <binit+0x40>
  }
}
801000be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801000c1:	c9                   	leave  
801000c2:	c3                   	ret    
801000c3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801000ca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801000d0 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801000d0:	55                   	push   %ebp
801000d1:	89 e5                	mov    %esp,%ebp
801000d3:	57                   	push   %edi
801000d4:	56                   	push   %esi
801000d5:	53                   	push   %ebx
801000d6:	83 ec 18             	sub    $0x18,%esp
801000d9:	8b 75 08             	mov    0x8(%ebp),%esi
801000dc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  acquire(&bcache.lock);
801000df:	68 20 b5 10 80       	push   $0x8010b520
801000e4:	e8 87 4a 00 00       	call   80104b70 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000e9:	8b 1d 70 fc 10 80    	mov    0x8010fc70,%ebx
801000ef:	83 c4 10             	add    $0x10,%esp
801000f2:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
801000f8:	75 11                	jne    8010010b <bread+0x3b>
801000fa:	eb 24                	jmp    80100120 <bread+0x50>
801000fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100100:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100103:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100109:	74 15                	je     80100120 <bread+0x50>
    if(b->dev == dev && b->blockno == blockno){
8010010b:	3b 73 04             	cmp    0x4(%ebx),%esi
8010010e:	75 f0                	jne    80100100 <bread+0x30>
80100110:	3b 7b 08             	cmp    0x8(%ebx),%edi
80100113:	75 eb                	jne    80100100 <bread+0x30>
      b->refcnt++;
80100115:	83 43 4c 01          	addl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
80100119:	eb 3f                	jmp    8010015a <bread+0x8a>
8010011b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010011f:	90                   	nop
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100120:	8b 1d 6c fc 10 80    	mov    0x8010fc6c,%ebx
80100126:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
8010012c:	75 0d                	jne    8010013b <bread+0x6b>
8010012e:	eb 6e                	jmp    8010019e <bread+0xce>
80100130:	8b 5b 50             	mov    0x50(%ebx),%ebx
80100133:	81 fb 1c fc 10 80    	cmp    $0x8010fc1c,%ebx
80100139:	74 63                	je     8010019e <bread+0xce>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
8010013b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010013e:	85 c0                	test   %eax,%eax
80100140:	75 ee                	jne    80100130 <bread+0x60>
80100142:	f6 03 04             	testb  $0x4,(%ebx)
80100145:	75 e9                	jne    80100130 <bread+0x60>
      b->dev = dev;
80100147:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
8010014a:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
8010014d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
80100153:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
8010015a:	83 ec 0c             	sub    $0xc,%esp
8010015d:	68 20 b5 10 80       	push   $0x8010b520
80100162:	e8 a9 49 00 00       	call   80104b10 <release>
      acquiresleep(&b->lock);
80100167:	8d 43 0c             	lea    0xc(%ebx),%eax
8010016a:	89 04 24             	mov    %eax,(%esp)
8010016d:	e8 3e 47 00 00       	call   801048b0 <acquiresleep>
      return b;
80100172:	83 c4 10             	add    $0x10,%esp
  struct buf *b;

  b = bget(dev, blockno);
  if((b->flags & B_VALID) == 0) {
80100175:	f6 03 02             	testb  $0x2,(%ebx)
80100178:	74 0e                	je     80100188 <bread+0xb8>
    iderw(b);
  }
  return b;
}
8010017a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010017d:	89 d8                	mov    %ebx,%eax
8010017f:	5b                   	pop    %ebx
80100180:	5e                   	pop    %esi
80100181:	5f                   	pop    %edi
80100182:	5d                   	pop    %ebp
80100183:	c3                   	ret    
80100184:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    iderw(b);
80100188:	83 ec 0c             	sub    $0xc,%esp
8010018b:	53                   	push   %ebx
8010018c:	e8 5f 21 00 00       	call   801022f0 <iderw>
80100191:	83 c4 10             	add    $0x10,%esp
}
80100194:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100197:	89 d8                	mov    %ebx,%eax
80100199:	5b                   	pop    %ebx
8010019a:	5e                   	pop    %esi
8010019b:	5f                   	pop    %edi
8010019c:	5d                   	pop    %ebp
8010019d:	c3                   	ret    
  panic("bget: no buffers");
8010019e:	83 ec 0c             	sub    $0xc,%esp
801001a1:	68 ae 7b 10 80       	push   $0x80107bae
801001a6:	e8 d5 01 00 00       	call   80100380 <panic>
801001ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801001af:	90                   	nop

801001b0 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
801001b0:	55                   	push   %ebp
801001b1:	89 e5                	mov    %esp,%ebp
801001b3:	53                   	push   %ebx
801001b4:	83 ec 10             	sub    $0x10,%esp
801001b7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001ba:	8d 43 0c             	lea    0xc(%ebx),%eax
801001bd:	50                   	push   %eax
801001be:	e8 8d 47 00 00       	call   80104950 <holdingsleep>
801001c3:	83 c4 10             	add    $0x10,%esp
801001c6:	85 c0                	test   %eax,%eax
801001c8:	74 0f                	je     801001d9 <bwrite+0x29>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001ca:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001cd:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
801001d0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001d3:	c9                   	leave  
  iderw(b);
801001d4:	e9 17 21 00 00       	jmp    801022f0 <iderw>
    panic("bwrite");
801001d9:	83 ec 0c             	sub    $0xc,%esp
801001dc:	68 bf 7b 10 80       	push   $0x80107bbf
801001e1:	e8 9a 01 00 00       	call   80100380 <panic>
801001e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801001ed:	8d 76 00             	lea    0x0(%esi),%esi

801001f0 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001f0:	55                   	push   %ebp
801001f1:	89 e5                	mov    %esp,%ebp
801001f3:	56                   	push   %esi
801001f4:	53                   	push   %ebx
801001f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001f8:	8d 73 0c             	lea    0xc(%ebx),%esi
801001fb:	83 ec 0c             	sub    $0xc,%esp
801001fe:	56                   	push   %esi
801001ff:	e8 4c 47 00 00       	call   80104950 <holdingsleep>
80100204:	83 c4 10             	add    $0x10,%esp
80100207:	85 c0                	test   %eax,%eax
80100209:	74 66                	je     80100271 <brelse+0x81>
    panic("brelse");

  releasesleep(&b->lock);
8010020b:	83 ec 0c             	sub    $0xc,%esp
8010020e:	56                   	push   %esi
8010020f:	e8 fc 46 00 00       	call   80104910 <releasesleep>

  acquire(&bcache.lock);
80100214:	c7 04 24 20 b5 10 80 	movl   $0x8010b520,(%esp)
8010021b:	e8 50 49 00 00       	call   80104b70 <acquire>
  b->refcnt--;
80100220:	8b 43 4c             	mov    0x4c(%ebx),%eax
  if (b->refcnt == 0) {
80100223:	83 c4 10             	add    $0x10,%esp
  b->refcnt--;
80100226:	83 e8 01             	sub    $0x1,%eax
80100229:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010022c:	85 c0                	test   %eax,%eax
8010022e:	75 2f                	jne    8010025f <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100230:	8b 43 54             	mov    0x54(%ebx),%eax
80100233:	8b 53 50             	mov    0x50(%ebx),%edx
80100236:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
80100239:	8b 43 50             	mov    0x50(%ebx),%eax
8010023c:	8b 53 54             	mov    0x54(%ebx),%edx
8010023f:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100242:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
    b->prev = &bcache.head;
80100247:	c7 43 50 1c fc 10 80 	movl   $0x8010fc1c,0x50(%ebx)
    b->next = bcache.head.next;
8010024e:	89 43 54             	mov    %eax,0x54(%ebx)
    bcache.head.next->prev = b;
80100251:	a1 70 fc 10 80       	mov    0x8010fc70,%eax
80100256:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100259:	89 1d 70 fc 10 80    	mov    %ebx,0x8010fc70
  }
  
  release(&bcache.lock);
8010025f:	c7 45 08 20 b5 10 80 	movl   $0x8010b520,0x8(%ebp)
}
80100266:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100269:	5b                   	pop    %ebx
8010026a:	5e                   	pop    %esi
8010026b:	5d                   	pop    %ebp
  release(&bcache.lock);
8010026c:	e9 9f 48 00 00       	jmp    80104b10 <release>
    panic("brelse");
80100271:	83 ec 0c             	sub    $0xc,%esp
80100274:	68 c6 7b 10 80       	push   $0x80107bc6
80100279:	e8 02 01 00 00       	call   80100380 <panic>
8010027e:	66 90                	xchg   %ax,%ax

80100280 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100280:	55                   	push   %ebp
80100281:	89 e5                	mov    %esp,%ebp
80100283:	57                   	push   %edi
80100284:	56                   	push   %esi
80100285:	53                   	push   %ebx
80100286:	83 ec 18             	sub    $0x18,%esp
80100289:	8b 5d 10             	mov    0x10(%ebp),%ebx
8010028c:	8b 75 0c             	mov    0xc(%ebp),%esi
  uint target;
  int c;

  iunlock(ip);
8010028f:	ff 75 08             	push   0x8(%ebp)
  target = n;
80100292:	89 df                	mov    %ebx,%edi
  iunlock(ip);
80100294:	e8 d7 15 00 00       	call   80101870 <iunlock>
  acquire(&cons.lock);
80100299:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801002a0:	e8 cb 48 00 00       	call   80104b70 <acquire>
  while(n > 0){
801002a5:	83 c4 10             	add    $0x10,%esp
801002a8:	85 db                	test   %ebx,%ebx
801002aa:	0f 8e 94 00 00 00    	jle    80100344 <consoleread+0xc4>
    while(input.r == input.w){
801002b0:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801002b5:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801002bb:	74 25                	je     801002e2 <consoleread+0x62>
801002bd:	eb 59                	jmp    80100318 <consoleread+0x98>
801002bf:	90                   	nop
      if(myproc()->killed){
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002c0:	83 ec 08             	sub    $0x8,%esp
801002c3:	68 20 ff 10 80       	push   $0x8010ff20
801002c8:	68 00 ff 10 80       	push   $0x8010ff00
801002cd:	e8 ee 3d 00 00       	call   801040c0 <sleep>
    while(input.r == input.w){
801002d2:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
801002d7:	83 c4 10             	add    $0x10,%esp
801002da:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801002e0:	75 36                	jne    80100318 <consoleread+0x98>
      if(myproc()->killed){
801002e2:	e8 c9 36 00 00       	call   801039b0 <myproc>
801002e7:	8b 48 24             	mov    0x24(%eax),%ecx
801002ea:	85 c9                	test   %ecx,%ecx
801002ec:	74 d2                	je     801002c0 <consoleread+0x40>
        release(&cons.lock);
801002ee:	83 ec 0c             	sub    $0xc,%esp
801002f1:	68 20 ff 10 80       	push   $0x8010ff20
801002f6:	e8 15 48 00 00       	call   80104b10 <release>
        ilock(ip);
801002fb:	5a                   	pop    %edx
801002fc:	ff 75 08             	push   0x8(%ebp)
801002ff:	e8 8c 14 00 00       	call   80101790 <ilock>
        return -1;
80100304:	83 c4 10             	add    $0x10,%esp
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
80100307:	8d 65 f4             	lea    -0xc(%ebp),%esp
        return -1;
8010030a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010030f:	5b                   	pop    %ebx
80100310:	5e                   	pop    %esi
80100311:	5f                   	pop    %edi
80100312:	5d                   	pop    %ebp
80100313:	c3                   	ret    
80100314:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    c = input.buf[input.r++ % INPUT_BUF];
80100318:	8d 50 01             	lea    0x1(%eax),%edx
8010031b:	89 15 00 ff 10 80    	mov    %edx,0x8010ff00
80100321:	89 c2                	mov    %eax,%edx
80100323:	83 e2 7f             	and    $0x7f,%edx
80100326:	0f be 8a 80 fe 10 80 	movsbl -0x7fef0180(%edx),%ecx
    if(c == C('D')){  // EOF
8010032d:	80 f9 04             	cmp    $0x4,%cl
80100330:	74 37                	je     80100369 <consoleread+0xe9>
    *dst++ = c;
80100332:	83 c6 01             	add    $0x1,%esi
    --n;
80100335:	83 eb 01             	sub    $0x1,%ebx
    *dst++ = c;
80100338:	88 4e ff             	mov    %cl,-0x1(%esi)
    if(c == '\n')
8010033b:	83 f9 0a             	cmp    $0xa,%ecx
8010033e:	0f 85 64 ff ff ff    	jne    801002a8 <consoleread+0x28>
  release(&cons.lock);
80100344:	83 ec 0c             	sub    $0xc,%esp
80100347:	68 20 ff 10 80       	push   $0x8010ff20
8010034c:	e8 bf 47 00 00       	call   80104b10 <release>
  ilock(ip);
80100351:	58                   	pop    %eax
80100352:	ff 75 08             	push   0x8(%ebp)
80100355:	e8 36 14 00 00       	call   80101790 <ilock>
  return target - n;
8010035a:	89 f8                	mov    %edi,%eax
8010035c:	83 c4 10             	add    $0x10,%esp
}
8010035f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return target - n;
80100362:	29 d8                	sub    %ebx,%eax
}
80100364:	5b                   	pop    %ebx
80100365:	5e                   	pop    %esi
80100366:	5f                   	pop    %edi
80100367:	5d                   	pop    %ebp
80100368:	c3                   	ret    
      if(n < target){
80100369:	39 fb                	cmp    %edi,%ebx
8010036b:	73 d7                	jae    80100344 <consoleread+0xc4>
        input.r--;
8010036d:	a3 00 ff 10 80       	mov    %eax,0x8010ff00
80100372:	eb d0                	jmp    80100344 <consoleread+0xc4>
80100374:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010037b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010037f:	90                   	nop

80100380 <panic>:
{
80100380:	55                   	push   %ebp
80100381:	89 e5                	mov    %esp,%ebp
80100383:	56                   	push   %esi
80100384:	53                   	push   %ebx
80100385:	83 ec 30             	sub    $0x30,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
80100388:	fa                   	cli    
  cons.locking = 0;
80100389:	c7 05 54 ff 10 80 00 	movl   $0x0,0x8010ff54
80100390:	00 00 00 
  getcallerpcs(&s, pcs);
80100393:	8d 5d d0             	lea    -0x30(%ebp),%ebx
80100396:	8d 75 f8             	lea    -0x8(%ebp),%esi
  cprintf("lapicid %d: panic: ", lapicid());
80100399:	e8 62 25 00 00       	call   80102900 <lapicid>
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	50                   	push   %eax
801003a2:	68 cd 7b 10 80       	push   $0x80107bcd
801003a7:	e8 f4 02 00 00       	call   801006a0 <cprintf>
  cprintf(s);
801003ac:	58                   	pop    %eax
801003ad:	ff 75 08             	push   0x8(%ebp)
801003b0:	e8 eb 02 00 00       	call   801006a0 <cprintf>
  cprintf("\n");
801003b5:	c7 04 24 63 85 10 80 	movl   $0x80108563,(%esp)
801003bc:	e8 df 02 00 00       	call   801006a0 <cprintf>
  getcallerpcs(&s, pcs);
801003c1:	8d 45 08             	lea    0x8(%ebp),%eax
801003c4:	5a                   	pop    %edx
801003c5:	59                   	pop    %ecx
801003c6:	53                   	push   %ebx
801003c7:	50                   	push   %eax
801003c8:	e8 f3 45 00 00       	call   801049c0 <getcallerpcs>
  for(i=0; i<10; i++)
801003cd:	83 c4 10             	add    $0x10,%esp
    cprintf(" %p", pcs[i]);
801003d0:	83 ec 08             	sub    $0x8,%esp
801003d3:	ff 33                	push   (%ebx)
  for(i=0; i<10; i++)
801003d5:	83 c3 04             	add    $0x4,%ebx
    cprintf(" %p", pcs[i]);
801003d8:	68 e1 7b 10 80       	push   $0x80107be1
801003dd:	e8 be 02 00 00       	call   801006a0 <cprintf>
  for(i=0; i<10; i++)
801003e2:	83 c4 10             	add    $0x10,%esp
801003e5:	39 f3                	cmp    %esi,%ebx
801003e7:	75 e7                	jne    801003d0 <panic+0x50>
  panicked = 1; // freeze other CPU
801003e9:	c7 05 58 ff 10 80 01 	movl   $0x1,0x8010ff58
801003f0:	00 00 00 
  for(;;)
801003f3:	eb fe                	jmp    801003f3 <panic+0x73>
801003f5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801003fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100400 <consputc.part.0>:
consputc(int c)
80100400:	55                   	push   %ebp
80100401:	89 e5                	mov    %esp,%ebp
80100403:	57                   	push   %edi
80100404:	56                   	push   %esi
80100405:	53                   	push   %ebx
80100406:	89 c3                	mov    %eax,%ebx
80100408:	83 ec 1c             	sub    $0x1c,%esp
  if(c == BACKSPACE){
8010040b:	3d 00 01 00 00       	cmp    $0x100,%eax
80100410:	0f 84 ea 00 00 00    	je     80100500 <consputc.part.0+0x100>
    uartputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	50                   	push   %eax
8010041a:	e8 11 62 00 00       	call   80106630 <uartputc>
8010041f:	83 c4 10             	add    $0x10,%esp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100422:	bf d4 03 00 00       	mov    $0x3d4,%edi
80100427:	b8 0e 00 00 00       	mov    $0xe,%eax
8010042c:	89 fa                	mov    %edi,%edx
8010042e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010042f:	be d5 03 00 00       	mov    $0x3d5,%esi
80100434:	89 f2                	mov    %esi,%edx
80100436:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
80100437:	0f b6 c8             	movzbl %al,%ecx
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010043a:	89 fa                	mov    %edi,%edx
8010043c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100441:	c1 e1 08             	shl    $0x8,%ecx
80100444:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80100445:	89 f2                	mov    %esi,%edx
80100447:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
80100448:	0f b6 c0             	movzbl %al,%eax
8010044b:	09 c8                	or     %ecx,%eax
  if(c == '\n')
8010044d:	83 fb 0a             	cmp    $0xa,%ebx
80100450:	0f 84 92 00 00 00    	je     801004e8 <consputc.part.0+0xe8>
  else if(c == BACKSPACE){
80100456:	81 fb 00 01 00 00    	cmp    $0x100,%ebx
8010045c:	74 72                	je     801004d0 <consputc.part.0+0xd0>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010045e:	0f b6 db             	movzbl %bl,%ebx
80100461:	8d 70 01             	lea    0x1(%eax),%esi
80100464:	80 cf 07             	or     $0x7,%bh
80100467:	66 89 9c 00 00 80 0b 	mov    %bx,-0x7ff48000(%eax,%eax,1)
8010046e:	80 
  if(pos < 0 || pos > 25*80)
8010046f:	81 fe d0 07 00 00    	cmp    $0x7d0,%esi
80100475:	0f 8f fb 00 00 00    	jg     80100576 <consputc.part.0+0x176>
  if((pos/80) >= 24){  // Scroll up.
8010047b:	81 fe 7f 07 00 00    	cmp    $0x77f,%esi
80100481:	0f 8f a9 00 00 00    	jg     80100530 <consputc.part.0+0x130>
  outb(CRTPORT+1, pos>>8);
80100487:	89 f0                	mov    %esi,%eax
  crt[pos] = ' ' | 0x0700;
80100489:	8d b4 36 00 80 0b 80 	lea    -0x7ff48000(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
80100490:	88 45 e7             	mov    %al,-0x19(%ebp)
  outb(CRTPORT+1, pos>>8);
80100493:	0f b6 fc             	movzbl %ah,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100496:	bb d4 03 00 00       	mov    $0x3d4,%ebx
8010049b:	b8 0e 00 00 00       	mov    $0xe,%eax
801004a0:	89 da                	mov    %ebx,%edx
801004a2:	ee                   	out    %al,(%dx)
801004a3:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
801004a8:	89 f8                	mov    %edi,%eax
801004aa:	89 ca                	mov    %ecx,%edx
801004ac:	ee                   	out    %al,(%dx)
801004ad:	b8 0f 00 00 00       	mov    $0xf,%eax
801004b2:	89 da                	mov    %ebx,%edx
801004b4:	ee                   	out    %al,(%dx)
801004b5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
801004b9:	89 ca                	mov    %ecx,%edx
801004bb:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
801004bc:	b8 20 07 00 00       	mov    $0x720,%eax
801004c1:	66 89 06             	mov    %ax,(%esi)
}
801004c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801004c7:	5b                   	pop    %ebx
801004c8:	5e                   	pop    %esi
801004c9:	5f                   	pop    %edi
801004ca:	5d                   	pop    %ebp
801004cb:	c3                   	ret    
801004cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(pos > 0) --pos;
801004d0:	8d 70 ff             	lea    -0x1(%eax),%esi
801004d3:	85 c0                	test   %eax,%eax
801004d5:	75 98                	jne    8010046f <consputc.part.0+0x6f>
801004d7:	c6 45 e7 00          	movb   $0x0,-0x19(%ebp)
801004db:	be 00 80 0b 80       	mov    $0x800b8000,%esi
801004e0:	31 ff                	xor    %edi,%edi
801004e2:	eb b2                	jmp    80100496 <consputc.part.0+0x96>
801004e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    pos += 80 - pos%80;
801004e8:	ba cd cc cc cc       	mov    $0xcccccccd,%edx
801004ed:	f7 e2                	mul    %edx
801004ef:	c1 ea 06             	shr    $0x6,%edx
801004f2:	8d 04 92             	lea    (%edx,%edx,4),%eax
801004f5:	c1 e0 04             	shl    $0x4,%eax
801004f8:	8d 70 50             	lea    0x50(%eax),%esi
801004fb:	e9 6f ff ff ff       	jmp    8010046f <consputc.part.0+0x6f>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100500:	83 ec 0c             	sub    $0xc,%esp
80100503:	6a 08                	push   $0x8
80100505:	e8 26 61 00 00       	call   80106630 <uartputc>
8010050a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
80100511:	e8 1a 61 00 00       	call   80106630 <uartputc>
80100516:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
8010051d:	e8 0e 61 00 00       	call   80106630 <uartputc>
80100522:	83 c4 10             	add    $0x10,%esp
80100525:	e9 f8 fe ff ff       	jmp    80100422 <consputc.part.0+0x22>
8010052a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100530:	83 ec 04             	sub    $0x4,%esp
    pos -= 80;
80100533:	8d 5e b0             	lea    -0x50(%esi),%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100536:	8d b4 36 60 7f 0b 80 	lea    -0x7ff480a0(%esi,%esi,1),%esi
  outb(CRTPORT+1, pos);
8010053d:	bf 07 00 00 00       	mov    $0x7,%edi
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
80100542:	68 60 0e 00 00       	push   $0xe60
80100547:	68 a0 80 0b 80       	push   $0x800b80a0
8010054c:	68 00 80 0b 80       	push   $0x800b8000
80100551:	e8 7a 47 00 00       	call   80104cd0 <memmove>
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
80100556:	b8 80 07 00 00       	mov    $0x780,%eax
8010055b:	83 c4 0c             	add    $0xc,%esp
8010055e:	29 d8                	sub    %ebx,%eax
80100560:	01 c0                	add    %eax,%eax
80100562:	50                   	push   %eax
80100563:	6a 00                	push   $0x0
80100565:	56                   	push   %esi
80100566:	e8 c5 46 00 00       	call   80104c30 <memset>
  outb(CRTPORT+1, pos);
8010056b:	88 5d e7             	mov    %bl,-0x19(%ebp)
8010056e:	83 c4 10             	add    $0x10,%esp
80100571:	e9 20 ff ff ff       	jmp    80100496 <consputc.part.0+0x96>
    panic("pos under/overflow");
80100576:	83 ec 0c             	sub    $0xc,%esp
80100579:	68 e5 7b 10 80       	push   $0x80107be5
8010057e:	e8 fd fd ff ff       	call   80100380 <panic>
80100583:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010058a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100590 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100590:	55                   	push   %ebp
80100591:	89 e5                	mov    %esp,%ebp
80100593:	57                   	push   %edi
80100594:	56                   	push   %esi
80100595:	53                   	push   %ebx
80100596:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100599:	ff 75 08             	push   0x8(%ebp)
{
8010059c:	8b 75 10             	mov    0x10(%ebp),%esi
  iunlock(ip);
8010059f:	e8 cc 12 00 00       	call   80101870 <iunlock>
  acquire(&cons.lock);
801005a4:	c7 04 24 20 ff 10 80 	movl   $0x8010ff20,(%esp)
801005ab:	e8 c0 45 00 00       	call   80104b70 <acquire>
  for(i = 0; i < n; i++)
801005b0:	83 c4 10             	add    $0x10,%esp
801005b3:	85 f6                	test   %esi,%esi
801005b5:	7e 25                	jle    801005dc <consolewrite+0x4c>
801005b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
801005ba:	8d 3c 33             	lea    (%ebx,%esi,1),%edi
  if(panicked){
801005bd:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
    consputc(buf[i] & 0xff);
801005c3:	0f b6 03             	movzbl (%ebx),%eax
  if(panicked){
801005c6:	85 d2                	test   %edx,%edx
801005c8:	74 06                	je     801005d0 <consolewrite+0x40>
  asm volatile("cli");
801005ca:	fa                   	cli    
    for(;;)
801005cb:	eb fe                	jmp    801005cb <consolewrite+0x3b>
801005cd:	8d 76 00             	lea    0x0(%esi),%esi
801005d0:	e8 2b fe ff ff       	call   80100400 <consputc.part.0>
  for(i = 0; i < n; i++)
801005d5:	83 c3 01             	add    $0x1,%ebx
801005d8:	39 df                	cmp    %ebx,%edi
801005da:	75 e1                	jne    801005bd <consolewrite+0x2d>
  release(&cons.lock);
801005dc:	83 ec 0c             	sub    $0xc,%esp
801005df:	68 20 ff 10 80       	push   $0x8010ff20
801005e4:	e8 27 45 00 00       	call   80104b10 <release>
  ilock(ip);
801005e9:	58                   	pop    %eax
801005ea:	ff 75 08             	push   0x8(%ebp)
801005ed:	e8 9e 11 00 00       	call   80101790 <ilock>

  return n;
}
801005f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801005f5:	89 f0                	mov    %esi,%eax
801005f7:	5b                   	pop    %ebx
801005f8:	5e                   	pop    %esi
801005f9:	5f                   	pop    %edi
801005fa:	5d                   	pop    %ebp
801005fb:	c3                   	ret    
801005fc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100600 <printint>:
{
80100600:	55                   	push   %ebp
80100601:	89 e5                	mov    %esp,%ebp
80100603:	57                   	push   %edi
80100604:	56                   	push   %esi
80100605:	53                   	push   %ebx
80100606:	83 ec 2c             	sub    $0x2c,%esp
80100609:	89 55 d4             	mov    %edx,-0x2c(%ebp)
8010060c:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  if(sign && (sign = xx < 0))
8010060f:	85 c9                	test   %ecx,%ecx
80100611:	74 04                	je     80100617 <printint+0x17>
80100613:	85 c0                	test   %eax,%eax
80100615:	78 6d                	js     80100684 <printint+0x84>
    x = xx;
80100617:	c7 45 d0 00 00 00 00 	movl   $0x0,-0x30(%ebp)
8010061e:	89 c1                	mov    %eax,%ecx
  i = 0;
80100620:	31 db                	xor    %ebx,%ebx
80100622:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    buf[i++] = digits[x % base];
80100628:	89 c8                	mov    %ecx,%eax
8010062a:	31 d2                	xor    %edx,%edx
8010062c:	89 de                	mov    %ebx,%esi
8010062e:	89 cf                	mov    %ecx,%edi
80100630:	f7 75 d4             	divl   -0x2c(%ebp)
80100633:	8d 5b 01             	lea    0x1(%ebx),%ebx
80100636:	0f b6 92 10 7c 10 80 	movzbl -0x7fef83f0(%edx),%edx
  }while((x /= base) != 0);
8010063d:	89 c1                	mov    %eax,%ecx
    buf[i++] = digits[x % base];
8010063f:	88 54 1d d7          	mov    %dl,-0x29(%ebp,%ebx,1)
  }while((x /= base) != 0);
80100643:	3b 7d d4             	cmp    -0x2c(%ebp),%edi
80100646:	73 e0                	jae    80100628 <printint+0x28>
  if(sign)
80100648:	8b 4d d0             	mov    -0x30(%ebp),%ecx
8010064b:	85 c9                	test   %ecx,%ecx
8010064d:	74 0c                	je     8010065b <printint+0x5b>
    buf[i++] = '-';
8010064f:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
    buf[i++] = digits[x % base];
80100654:	89 de                	mov    %ebx,%esi
    buf[i++] = '-';
80100656:	ba 2d 00 00 00       	mov    $0x2d,%edx
  while(--i >= 0)
8010065b:	8d 5c 35 d7          	lea    -0x29(%ebp,%esi,1),%ebx
8010065f:	0f be c2             	movsbl %dl,%eax
  if(panicked){
80100662:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100668:	85 d2                	test   %edx,%edx
8010066a:	74 04                	je     80100670 <printint+0x70>
8010066c:	fa                   	cli    
    for(;;)
8010066d:	eb fe                	jmp    8010066d <printint+0x6d>
8010066f:	90                   	nop
80100670:	e8 8b fd ff ff       	call   80100400 <consputc.part.0>
  while(--i >= 0)
80100675:	8d 45 d7             	lea    -0x29(%ebp),%eax
80100678:	39 c3                	cmp    %eax,%ebx
8010067a:	74 0e                	je     8010068a <printint+0x8a>
    consputc(buf[i]);
8010067c:	0f be 03             	movsbl (%ebx),%eax
8010067f:	83 eb 01             	sub    $0x1,%ebx
80100682:	eb de                	jmp    80100662 <printint+0x62>
    x = -xx;
80100684:	f7 d8                	neg    %eax
80100686:	89 c1                	mov    %eax,%ecx
80100688:	eb 96                	jmp    80100620 <printint+0x20>
}
8010068a:	83 c4 2c             	add    $0x2c,%esp
8010068d:	5b                   	pop    %ebx
8010068e:	5e                   	pop    %esi
8010068f:	5f                   	pop    %edi
80100690:	5d                   	pop    %ebp
80100691:	c3                   	ret    
80100692:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100699:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801006a0 <cprintf>:
{
801006a0:	55                   	push   %ebp
801006a1:	89 e5                	mov    %esp,%ebp
801006a3:	57                   	push   %edi
801006a4:	56                   	push   %esi
801006a5:	53                   	push   %ebx
801006a6:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
801006a9:	a1 54 ff 10 80       	mov    0x8010ff54,%eax
801006ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
801006b1:	85 c0                	test   %eax,%eax
801006b3:	0f 85 27 01 00 00    	jne    801007e0 <cprintf+0x140>
  if (fmt == 0)
801006b9:	8b 75 08             	mov    0x8(%ebp),%esi
801006bc:	85 f6                	test   %esi,%esi
801006be:	0f 84 ac 01 00 00    	je     80100870 <cprintf+0x1d0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006c4:	0f b6 06             	movzbl (%esi),%eax
  argp = (uint*)(void*)(&fmt + 1);
801006c7:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801006ca:	31 db                	xor    %ebx,%ebx
801006cc:	85 c0                	test   %eax,%eax
801006ce:	74 56                	je     80100726 <cprintf+0x86>
    if(c != '%'){
801006d0:	83 f8 25             	cmp    $0x25,%eax
801006d3:	0f 85 cf 00 00 00    	jne    801007a8 <cprintf+0x108>
    c = fmt[++i] & 0xff;
801006d9:	83 c3 01             	add    $0x1,%ebx
801006dc:	0f b6 14 1e          	movzbl (%esi,%ebx,1),%edx
    if(c == 0)
801006e0:	85 d2                	test   %edx,%edx
801006e2:	74 42                	je     80100726 <cprintf+0x86>
    switch(c){
801006e4:	83 fa 70             	cmp    $0x70,%edx
801006e7:	0f 84 90 00 00 00    	je     8010077d <cprintf+0xdd>
801006ed:	7f 51                	jg     80100740 <cprintf+0xa0>
801006ef:	83 fa 25             	cmp    $0x25,%edx
801006f2:	0f 84 c0 00 00 00    	je     801007b8 <cprintf+0x118>
801006f8:	83 fa 64             	cmp    $0x64,%edx
801006fb:	0f 85 f4 00 00 00    	jne    801007f5 <cprintf+0x155>
      printint(*argp++, 10, 1);
80100701:	8d 47 04             	lea    0x4(%edi),%eax
80100704:	b9 01 00 00 00       	mov    $0x1,%ecx
80100709:	ba 0a 00 00 00       	mov    $0xa,%edx
8010070e:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100711:	8b 07                	mov    (%edi),%eax
80100713:	e8 e8 fe ff ff       	call   80100600 <printint>
80100718:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010071b:	83 c3 01             	add    $0x1,%ebx
8010071e:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
80100722:	85 c0                	test   %eax,%eax
80100724:	75 aa                	jne    801006d0 <cprintf+0x30>
  if(locking)
80100726:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100729:	85 c0                	test   %eax,%eax
8010072b:	0f 85 22 01 00 00    	jne    80100853 <cprintf+0x1b3>
}
80100731:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100734:	5b                   	pop    %ebx
80100735:	5e                   	pop    %esi
80100736:	5f                   	pop    %edi
80100737:	5d                   	pop    %ebp
80100738:	c3                   	ret    
80100739:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100740:	83 fa 73             	cmp    $0x73,%edx
80100743:	75 33                	jne    80100778 <cprintf+0xd8>
      if((s = (char*)*argp++) == 0)
80100745:	8d 47 04             	lea    0x4(%edi),%eax
80100748:	8b 3f                	mov    (%edi),%edi
8010074a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010074d:	85 ff                	test   %edi,%edi
8010074f:	0f 84 e3 00 00 00    	je     80100838 <cprintf+0x198>
      for(; *s; s++)
80100755:	0f be 07             	movsbl (%edi),%eax
80100758:	84 c0                	test   %al,%al
8010075a:	0f 84 08 01 00 00    	je     80100868 <cprintf+0x1c8>
  if(panicked){
80100760:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100766:	85 d2                	test   %edx,%edx
80100768:	0f 84 b2 00 00 00    	je     80100820 <cprintf+0x180>
8010076e:	fa                   	cli    
    for(;;)
8010076f:	eb fe                	jmp    8010076f <cprintf+0xcf>
80100771:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    switch(c){
80100778:	83 fa 78             	cmp    $0x78,%edx
8010077b:	75 78                	jne    801007f5 <cprintf+0x155>
      printint(*argp++, 16, 0);
8010077d:	8d 47 04             	lea    0x4(%edi),%eax
80100780:	31 c9                	xor    %ecx,%ecx
80100782:	ba 10 00 00 00       	mov    $0x10,%edx
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100787:	83 c3 01             	add    $0x1,%ebx
      printint(*argp++, 16, 0);
8010078a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010078d:	8b 07                	mov    (%edi),%eax
8010078f:	e8 6c fe ff ff       	call   80100600 <printint>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100794:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
      printint(*argp++, 16, 0);
80100798:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
8010079b:	85 c0                	test   %eax,%eax
8010079d:	0f 85 2d ff ff ff    	jne    801006d0 <cprintf+0x30>
801007a3:	eb 81                	jmp    80100726 <cprintf+0x86>
801007a5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801007a8:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
801007ae:	85 c9                	test   %ecx,%ecx
801007b0:	74 14                	je     801007c6 <cprintf+0x126>
801007b2:	fa                   	cli    
    for(;;)
801007b3:	eb fe                	jmp    801007b3 <cprintf+0x113>
801007b5:	8d 76 00             	lea    0x0(%esi),%esi
  if(panicked){
801007b8:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
801007bd:	85 c0                	test   %eax,%eax
801007bf:	75 6c                	jne    8010082d <cprintf+0x18d>
801007c1:	b8 25 00 00 00       	mov    $0x25,%eax
801007c6:	e8 35 fc ff ff       	call   80100400 <consputc.part.0>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
801007cb:	83 c3 01             	add    $0x1,%ebx
801007ce:	0f b6 04 1e          	movzbl (%esi,%ebx,1),%eax
801007d2:	85 c0                	test   %eax,%eax
801007d4:	0f 85 f6 fe ff ff    	jne    801006d0 <cprintf+0x30>
801007da:	e9 47 ff ff ff       	jmp    80100726 <cprintf+0x86>
801007df:	90                   	nop
    acquire(&cons.lock);
801007e0:	83 ec 0c             	sub    $0xc,%esp
801007e3:	68 20 ff 10 80       	push   $0x8010ff20
801007e8:	e8 83 43 00 00       	call   80104b70 <acquire>
801007ed:	83 c4 10             	add    $0x10,%esp
801007f0:	e9 c4 fe ff ff       	jmp    801006b9 <cprintf+0x19>
  if(panicked){
801007f5:	8b 0d 58 ff 10 80    	mov    0x8010ff58,%ecx
801007fb:	85 c9                	test   %ecx,%ecx
801007fd:	75 31                	jne    80100830 <cprintf+0x190>
801007ff:	b8 25 00 00 00       	mov    $0x25,%eax
80100804:	89 55 e0             	mov    %edx,-0x20(%ebp)
80100807:	e8 f4 fb ff ff       	call   80100400 <consputc.part.0>
8010080c:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
80100812:	85 d2                	test   %edx,%edx
80100814:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100817:	74 2e                	je     80100847 <cprintf+0x1a7>
80100819:	fa                   	cli    
    for(;;)
8010081a:	eb fe                	jmp    8010081a <cprintf+0x17a>
8010081c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100820:	e8 db fb ff ff       	call   80100400 <consputc.part.0>
      for(; *s; s++)
80100825:	83 c7 01             	add    $0x1,%edi
80100828:	e9 28 ff ff ff       	jmp    80100755 <cprintf+0xb5>
8010082d:	fa                   	cli    
    for(;;)
8010082e:	eb fe                	jmp    8010082e <cprintf+0x18e>
80100830:	fa                   	cli    
80100831:	eb fe                	jmp    80100831 <cprintf+0x191>
80100833:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100837:	90                   	nop
        s = "(null)";
80100838:	bf f8 7b 10 80       	mov    $0x80107bf8,%edi
      for(; *s; s++)
8010083d:	b8 28 00 00 00       	mov    $0x28,%eax
80100842:	e9 19 ff ff ff       	jmp    80100760 <cprintf+0xc0>
80100847:	89 d0                	mov    %edx,%eax
80100849:	e8 b2 fb ff ff       	call   80100400 <consputc.part.0>
8010084e:	e9 c8 fe ff ff       	jmp    8010071b <cprintf+0x7b>
    release(&cons.lock);
80100853:	83 ec 0c             	sub    $0xc,%esp
80100856:	68 20 ff 10 80       	push   $0x8010ff20
8010085b:	e8 b0 42 00 00       	call   80104b10 <release>
80100860:	83 c4 10             	add    $0x10,%esp
}
80100863:	e9 c9 fe ff ff       	jmp    80100731 <cprintf+0x91>
      if((s = (char*)*argp++) == 0)
80100868:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010086b:	e9 ab fe ff ff       	jmp    8010071b <cprintf+0x7b>
    panic("null fmt");
80100870:	83 ec 0c             	sub    $0xc,%esp
80100873:	68 ff 7b 10 80       	push   $0x80107bff
80100878:	e8 03 fb ff ff       	call   80100380 <panic>
8010087d:	8d 76 00             	lea    0x0(%esi),%esi

80100880 <consoleintr>:
{
80100880:	55                   	push   %ebp
80100881:	89 e5                	mov    %esp,%ebp
80100883:	57                   	push   %edi
80100884:	56                   	push   %esi
  int c, doprocdump = 0;
80100885:	31 f6                	xor    %esi,%esi
{
80100887:	53                   	push   %ebx
80100888:	83 ec 18             	sub    $0x18,%esp
8010088b:	8b 7d 08             	mov    0x8(%ebp),%edi
  acquire(&cons.lock);
8010088e:	68 20 ff 10 80       	push   $0x8010ff20
80100893:	e8 d8 42 00 00       	call   80104b70 <acquire>
  while((c = getc()) >= 0){
80100898:	83 c4 10             	add    $0x10,%esp
8010089b:	eb 1a                	jmp    801008b7 <consoleintr+0x37>
8010089d:	8d 76 00             	lea    0x0(%esi),%esi
    switch(c){
801008a0:	83 fb 08             	cmp    $0x8,%ebx
801008a3:	0f 84 d7 00 00 00    	je     80100980 <consoleintr+0x100>
801008a9:	83 fb 10             	cmp    $0x10,%ebx
801008ac:	0f 85 32 01 00 00    	jne    801009e4 <consoleintr+0x164>
801008b2:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
801008b7:	ff d7                	call   *%edi
801008b9:	89 c3                	mov    %eax,%ebx
801008bb:	85 c0                	test   %eax,%eax
801008bd:	0f 88 05 01 00 00    	js     801009c8 <consoleintr+0x148>
    switch(c){
801008c3:	83 fb 15             	cmp    $0x15,%ebx
801008c6:	74 78                	je     80100940 <consoleintr+0xc0>
801008c8:	7e d6                	jle    801008a0 <consoleintr+0x20>
801008ca:	83 fb 7f             	cmp    $0x7f,%ebx
801008cd:	0f 84 ad 00 00 00    	je     80100980 <consoleintr+0x100>
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008d3:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
801008d8:	89 c2                	mov    %eax,%edx
801008da:	2b 15 00 ff 10 80    	sub    0x8010ff00,%edx
801008e0:	83 fa 7f             	cmp    $0x7f,%edx
801008e3:	77 d2                	ja     801008b7 <consoleintr+0x37>
        input.buf[input.e++ % INPUT_BUF] = c;
801008e5:	8d 48 01             	lea    0x1(%eax),%ecx
  if(panicked){
801008e8:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
        input.buf[input.e++ % INPUT_BUF] = c;
801008ee:	83 e0 7f             	and    $0x7f,%eax
801008f1:	89 0d 08 ff 10 80    	mov    %ecx,0x8010ff08
        c = (c == '\r') ? '\n' : c;
801008f7:	83 fb 0d             	cmp    $0xd,%ebx
801008fa:	0f 84 13 01 00 00    	je     80100a13 <consoleintr+0x193>
        input.buf[input.e++ % INPUT_BUF] = c;
80100900:	88 98 80 fe 10 80    	mov    %bl,-0x7fef0180(%eax)
  if(panicked){
80100906:	85 d2                	test   %edx,%edx
80100908:	0f 85 10 01 00 00    	jne    80100a1e <consoleintr+0x19e>
8010090e:	89 d8                	mov    %ebx,%eax
80100910:	e8 eb fa ff ff       	call   80100400 <consputc.part.0>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100915:	83 fb 0a             	cmp    $0xa,%ebx
80100918:	0f 84 14 01 00 00    	je     80100a32 <consoleintr+0x1b2>
8010091e:	83 fb 04             	cmp    $0x4,%ebx
80100921:	0f 84 0b 01 00 00    	je     80100a32 <consoleintr+0x1b2>
80100927:	a1 00 ff 10 80       	mov    0x8010ff00,%eax
8010092c:	83 e8 80             	sub    $0xffffff80,%eax
8010092f:	39 05 08 ff 10 80    	cmp    %eax,0x8010ff08
80100935:	75 80                	jne    801008b7 <consoleintr+0x37>
80100937:	e9 fb 00 00 00       	jmp    80100a37 <consoleintr+0x1b7>
8010093c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      while(input.e != input.w &&
80100940:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100945:	39 05 04 ff 10 80    	cmp    %eax,0x8010ff04
8010094b:	0f 84 66 ff ff ff    	je     801008b7 <consoleintr+0x37>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100951:	83 e8 01             	sub    $0x1,%eax
80100954:	89 c2                	mov    %eax,%edx
80100956:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
80100959:	80 ba 80 fe 10 80 0a 	cmpb   $0xa,-0x7fef0180(%edx)
80100960:	0f 84 51 ff ff ff    	je     801008b7 <consoleintr+0x37>
  if(panicked){
80100966:	8b 15 58 ff 10 80    	mov    0x8010ff58,%edx
        input.e--;
8010096c:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100971:	85 d2                	test   %edx,%edx
80100973:	74 33                	je     801009a8 <consoleintr+0x128>
80100975:	fa                   	cli    
    for(;;)
80100976:	eb fe                	jmp    80100976 <consoleintr+0xf6>
80100978:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010097f:	90                   	nop
      if(input.e != input.w){
80100980:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
80100985:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
8010098b:	0f 84 26 ff ff ff    	je     801008b7 <consoleintr+0x37>
        input.e--;
80100991:	83 e8 01             	sub    $0x1,%eax
80100994:	a3 08 ff 10 80       	mov    %eax,0x8010ff08
  if(panicked){
80100999:	a1 58 ff 10 80       	mov    0x8010ff58,%eax
8010099e:	85 c0                	test   %eax,%eax
801009a0:	74 56                	je     801009f8 <consoleintr+0x178>
801009a2:	fa                   	cli    
    for(;;)
801009a3:	eb fe                	jmp    801009a3 <consoleintr+0x123>
801009a5:	8d 76 00             	lea    0x0(%esi),%esi
801009a8:	b8 00 01 00 00       	mov    $0x100,%eax
801009ad:	e8 4e fa ff ff       	call   80100400 <consputc.part.0>
      while(input.e != input.w &&
801009b2:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
801009b7:	3b 05 04 ff 10 80    	cmp    0x8010ff04,%eax
801009bd:	75 92                	jne    80100951 <consoleintr+0xd1>
801009bf:	e9 f3 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
801009c4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&cons.lock);
801009c8:	83 ec 0c             	sub    $0xc,%esp
801009cb:	68 20 ff 10 80       	push   $0x8010ff20
801009d0:	e8 3b 41 00 00       	call   80104b10 <release>
  if(doprocdump) {
801009d5:	83 c4 10             	add    $0x10,%esp
801009d8:	85 f6                	test   %esi,%esi
801009da:	75 2b                	jne    80100a07 <consoleintr+0x187>
}
801009dc:	8d 65 f4             	lea    -0xc(%ebp),%esp
801009df:	5b                   	pop    %ebx
801009e0:	5e                   	pop    %esi
801009e1:	5f                   	pop    %edi
801009e2:	5d                   	pop    %ebp
801009e3:	c3                   	ret    
      if(c != 0 && input.e-input.r < INPUT_BUF){
801009e4:	85 db                	test   %ebx,%ebx
801009e6:	0f 84 cb fe ff ff    	je     801008b7 <consoleintr+0x37>
801009ec:	e9 e2 fe ff ff       	jmp    801008d3 <consoleintr+0x53>
801009f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801009f8:	b8 00 01 00 00       	mov    $0x100,%eax
801009fd:	e8 fe f9 ff ff       	call   80100400 <consputc.part.0>
80100a02:	e9 b0 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
}
80100a07:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100a0a:	5b                   	pop    %ebx
80100a0b:	5e                   	pop    %esi
80100a0c:	5f                   	pop    %edi
80100a0d:	5d                   	pop    %ebp
    procdump();  // now call procdump() wo. cons.lock held
80100a0e:	e9 4d 38 00 00       	jmp    80104260 <procdump>
        input.buf[input.e++ % INPUT_BUF] = c;
80100a13:	c6 80 80 fe 10 80 0a 	movb   $0xa,-0x7fef0180(%eax)
  if(panicked){
80100a1a:	85 d2                	test   %edx,%edx
80100a1c:	74 0a                	je     80100a28 <consoleintr+0x1a8>
80100a1e:	fa                   	cli    
    for(;;)
80100a1f:	eb fe                	jmp    80100a1f <consoleintr+0x19f>
80100a21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a28:	b8 0a 00 00 00       	mov    $0xa,%eax
80100a2d:	e8 ce f9 ff ff       	call   80100400 <consputc.part.0>
          input.w = input.e;
80100a32:	a1 08 ff 10 80       	mov    0x8010ff08,%eax
          wakeup(&input.r);
80100a37:	83 ec 0c             	sub    $0xc,%esp
          input.w = input.e;
80100a3a:	a3 04 ff 10 80       	mov    %eax,0x8010ff04
          wakeup(&input.r);
80100a3f:	68 00 ff 10 80       	push   $0x8010ff00
80100a44:	e8 37 37 00 00       	call   80104180 <wakeup>
80100a49:	83 c4 10             	add    $0x10,%esp
80100a4c:	e9 66 fe ff ff       	jmp    801008b7 <consoleintr+0x37>
80100a51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a58:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100a5f:	90                   	nop

80100a60 <consoleinit>:

void
consoleinit(void)
{
80100a60:	55                   	push   %ebp
80100a61:	89 e5                	mov    %esp,%ebp
80100a63:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100a66:	68 08 7c 10 80       	push   $0x80107c08
80100a6b:	68 20 ff 10 80       	push   $0x8010ff20
80100a70:	e8 2b 3f 00 00       	call   801049a0 <initlock>

  devsw[CONSOLE].write = consolewrite;
  devsw[CONSOLE].read = consoleread;
  cons.locking = 1;

  ioapicenable(IRQ_KBD, 0);
80100a75:	58                   	pop    %eax
80100a76:	5a                   	pop    %edx
80100a77:	6a 00                	push   $0x0
80100a79:	6a 01                	push   $0x1
  devsw[CONSOLE].write = consolewrite;
80100a7b:	c7 05 0c 09 11 80 90 	movl   $0x80100590,0x8011090c
80100a82:	05 10 80 
  devsw[CONSOLE].read = consoleread;
80100a85:	c7 05 08 09 11 80 80 	movl   $0x80100280,0x80110908
80100a8c:	02 10 80 
  cons.locking = 1;
80100a8f:	c7 05 54 ff 10 80 01 	movl   $0x1,0x8010ff54
80100a96:	00 00 00 
  ioapicenable(IRQ_KBD, 0);
80100a99:	e8 f2 19 00 00       	call   80102490 <ioapicenable>
}
80100a9e:	83 c4 10             	add    $0x10,%esp
80100aa1:	c9                   	leave  
80100aa2:	c3                   	ret    
80100aa3:	66 90                	xchg   %ax,%ax
80100aa5:	66 90                	xchg   %ax,%ax
80100aa7:	66 90                	xchg   %ax,%ax
80100aa9:	66 90                	xchg   %ax,%ax
80100aab:	66 90                	xchg   %ax,%ax
80100aad:	66 90                	xchg   %ax,%ax
80100aaf:	90                   	nop

80100ab0 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100ab0:	55                   	push   %ebp
80100ab1:	89 e5                	mov    %esp,%ebp
80100ab3:	57                   	push   %edi
80100ab4:	56                   	push   %esi
80100ab5:	53                   	push   %ebx
80100ab6:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
80100abc:	e8 ef 2e 00 00       	call   801039b0 <myproc>
80100ac1:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)

  begin_op();
80100ac7:	e8 a4 22 00 00       	call   80102d70 <begin_op>

  if((ip = namei(path)) == 0){
80100acc:	83 ec 0c             	sub    $0xc,%esp
80100acf:	ff 75 08             	push   0x8(%ebp)
80100ad2:	e8 d9 15 00 00       	call   801020b0 <namei>
80100ad7:	83 c4 10             	add    $0x10,%esp
80100ada:	85 c0                	test   %eax,%eax
80100adc:	0f 84 12 03 00 00    	je     80100df4 <exec+0x344>
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100ae2:	83 ec 0c             	sub    $0xc,%esp
80100ae5:	89 c3                	mov    %eax,%ebx
80100ae7:	50                   	push   %eax
80100ae8:	e8 a3 0c 00 00       	call   80101790 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
80100aed:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100af3:	6a 34                	push   $0x34
80100af5:	6a 00                	push   $0x0
80100af7:	50                   	push   %eax
80100af8:	53                   	push   %ebx
80100af9:	e8 a2 0f 00 00       	call   80101aa0 <readi>
80100afe:	83 c4 20             	add    $0x20,%esp
80100b01:	83 f8 34             	cmp    $0x34,%eax
80100b04:	74 22                	je     80100b28 <exec+0x78>

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
    iunlockput(ip);
80100b06:	83 ec 0c             	sub    $0xc,%esp
80100b09:	53                   	push   %ebx
80100b0a:	e8 11 0f 00 00       	call   80101a20 <iunlockput>
    end_op();
80100b0f:	e8 cc 22 00 00       	call   80102de0 <end_op>
80100b14:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
80100b17:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100b1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100b1f:	5b                   	pop    %ebx
80100b20:	5e                   	pop    %esi
80100b21:	5f                   	pop    %edi
80100b22:	5d                   	pop    %ebp
80100b23:	c3                   	ret    
80100b24:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(elf.magic != ELF_MAGIC)
80100b28:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
80100b2f:	45 4c 46 
80100b32:	75 d2                	jne    80100b06 <exec+0x56>
  if((pgdir = setupkvm()) == 0)
80100b34:	e8 27 6d 00 00       	call   80107860 <setupkvm>
80100b39:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)
80100b3f:	85 c0                	test   %eax,%eax
80100b41:	74 c3                	je     80100b06 <exec+0x56>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b43:	66 83 bd 50 ff ff ff 	cmpw   $0x0,-0xb0(%ebp)
80100b4a:	00 
80100b4b:	8b b5 40 ff ff ff    	mov    -0xc0(%ebp),%esi
80100b51:	0f 84 bc 02 00 00    	je     80100e13 <exec+0x363>
  sz = 0;
80100b57:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
80100b5e:	00 00 00 
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100b61:	31 ff                	xor    %edi,%edi
80100b63:	e9 98 00 00 00       	jmp    80100c00 <exec+0x150>
80100b68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100b6f:	90                   	nop
    if(ph.type != ELF_PROG_LOAD)
80100b70:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
80100b77:	75 76                	jne    80100bef <exec+0x13f>
    if(ph.memsz < ph.filesz)
80100b79:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
80100b7f:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
80100b85:	0f 82 91 00 00 00    	jb     80100c1c <exec+0x16c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
80100b8b:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
80100b91:	0f 82 85 00 00 00    	jb     80100c1c <exec+0x16c>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100b97:	83 ec 04             	sub    $0x4,%esp
80100b9a:	50                   	push   %eax
80100b9b:	ff b5 f0 fe ff ff    	push   -0x110(%ebp)
80100ba1:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100ba7:	e8 d4 6a 00 00       	call   80107680 <allocuvm>
80100bac:	83 c4 10             	add    $0x10,%esp
80100baf:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100bb5:	85 c0                	test   %eax,%eax
80100bb7:	74 63                	je     80100c1c <exec+0x16c>
    if(ph.vaddr % PGSIZE != 0)
80100bb9:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bbf:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100bc4:	75 56                	jne    80100c1c <exec+0x16c>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz, ph.flags) < 0)
80100bc6:	83 ec 08             	sub    $0x8,%esp
80100bc9:	ff b5 1c ff ff ff    	push   -0xe4(%ebp)
80100bcf:	ff b5 14 ff ff ff    	push   -0xec(%ebp)
80100bd5:	ff b5 08 ff ff ff    	push   -0xf8(%ebp)
80100bdb:	53                   	push   %ebx
80100bdc:	50                   	push   %eax
80100bdd:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100be3:	e8 98 69 00 00       	call   80107580 <loaduvm>
80100be8:	83 c4 20             	add    $0x20,%esp
80100beb:	85 c0                	test   %eax,%eax
80100bed:	78 2d                	js     80100c1c <exec+0x16c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100bef:	0f b7 85 50 ff ff ff 	movzwl -0xb0(%ebp),%eax
80100bf6:	83 c7 01             	add    $0x1,%edi
80100bf9:	83 c6 20             	add    $0x20,%esi
80100bfc:	39 f8                	cmp    %edi,%eax
80100bfe:	7e 38                	jle    80100c38 <exec+0x188>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100c00:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
80100c06:	6a 20                	push   $0x20
80100c08:	56                   	push   %esi
80100c09:	50                   	push   %eax
80100c0a:	53                   	push   %ebx
80100c0b:	e8 90 0e 00 00       	call   80101aa0 <readi>
80100c10:	83 c4 10             	add    $0x10,%esp
80100c13:	83 f8 20             	cmp    $0x20,%eax
80100c16:	0f 84 54 ff ff ff    	je     80100b70 <exec+0xc0>
    freevm(pgdir);
80100c1c:	83 ec 0c             	sub    $0xc,%esp
80100c1f:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100c25:	e8 b6 6b 00 00       	call   801077e0 <freevm>
  if(ip){
80100c2a:	83 c4 10             	add    $0x10,%esp
80100c2d:	e9 d4 fe ff ff       	jmp    80100b06 <exec+0x56>
80100c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  sz = PGROUNDUP(sz);
80100c38:	8b bd f0 fe ff ff    	mov    -0x110(%ebp),%edi
80100c3e:	81 c7 ff 0f 00 00    	add    $0xfff,%edi
80100c44:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c4a:	8d b7 00 20 00 00    	lea    0x2000(%edi),%esi
  iunlockput(ip);
80100c50:	83 ec 0c             	sub    $0xc,%esp
80100c53:	53                   	push   %ebx
80100c54:	e8 c7 0d 00 00       	call   80101a20 <iunlockput>
  end_op();
80100c59:	e8 82 21 00 00       	call   80102de0 <end_op>
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100c5e:	83 c4 0c             	add    $0xc,%esp
80100c61:	56                   	push   %esi
80100c62:	57                   	push   %edi
80100c63:	8b bd f4 fe ff ff    	mov    -0x10c(%ebp),%edi
80100c69:	57                   	push   %edi
80100c6a:	e8 11 6a 00 00       	call   80107680 <allocuvm>
80100c6f:	83 c4 10             	add    $0x10,%esp
80100c72:	89 c6                	mov    %eax,%esi
80100c74:	85 c0                	test   %eax,%eax
80100c76:	0f 84 94 00 00 00    	je     80100d10 <exec+0x260>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c7c:	83 ec 08             	sub    $0x8,%esp
80100c7f:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
  for(argc = 0; argv[argc]; argc++) {
80100c85:	89 f3                	mov    %esi,%ebx
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c87:	50                   	push   %eax
80100c88:	57                   	push   %edi
  for(argc = 0; argv[argc]; argc++) {
80100c89:	31 ff                	xor    %edi,%edi
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100c8b:	e8 70 6c 00 00       	call   80107900 <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100c90:	8b 45 0c             	mov    0xc(%ebp),%eax
80100c93:	83 c4 10             	add    $0x10,%esp
80100c96:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
80100c9c:	8b 00                	mov    (%eax),%eax
80100c9e:	85 c0                	test   %eax,%eax
80100ca0:	0f 84 8b 00 00 00    	je     80100d31 <exec+0x281>
80100ca6:	89 b5 f0 fe ff ff    	mov    %esi,-0x110(%ebp)
80100cac:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100cb2:	eb 23                	jmp    80100cd7 <exec+0x227>
80100cb4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100cb8:	8b 45 0c             	mov    0xc(%ebp),%eax
    ustack[3+argc] = sp;
80100cbb:	89 9c bd 64 ff ff ff 	mov    %ebx,-0x9c(%ebp,%edi,4)
  for(argc = 0; argv[argc]; argc++) {
80100cc2:	83 c7 01             	add    $0x1,%edi
    ustack[3+argc] = sp;
80100cc5:	8d 95 58 ff ff ff    	lea    -0xa8(%ebp),%edx
  for(argc = 0; argv[argc]; argc++) {
80100ccb:	8b 04 b8             	mov    (%eax,%edi,4),%eax
80100cce:	85 c0                	test   %eax,%eax
80100cd0:	74 59                	je     80100d2b <exec+0x27b>
    if(argc >= MAXARG)
80100cd2:	83 ff 20             	cmp    $0x20,%edi
80100cd5:	74 39                	je     80100d10 <exec+0x260>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cd7:	83 ec 0c             	sub    $0xc,%esp
80100cda:	50                   	push   %eax
80100cdb:	e8 50 41 00 00       	call   80104e30 <strlen>
80100ce0:	29 c3                	sub    %eax,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ce2:	58                   	pop    %eax
80100ce3:	8b 45 0c             	mov    0xc(%ebp),%eax
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ce6:	83 eb 01             	sub    $0x1,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100ce9:	ff 34 b8             	push   (%eax,%edi,4)
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100cec:	83 e3 fc             	and    $0xfffffffc,%ebx
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100cef:	e8 3c 41 00 00       	call   80104e30 <strlen>
80100cf4:	83 c0 01             	add    $0x1,%eax
80100cf7:	50                   	push   %eax
80100cf8:	8b 45 0c             	mov    0xc(%ebp),%eax
80100cfb:	ff 34 b8             	push   (%eax,%edi,4)
80100cfe:	53                   	push   %ebx
80100cff:	56                   	push   %esi
80100d00:	e8 bb 6d 00 00       	call   80107ac0 <copyout>
80100d05:	83 c4 20             	add    $0x20,%esp
80100d08:	85 c0                	test   %eax,%eax
80100d0a:	79 ac                	jns    80100cb8 <exec+0x208>
80100d0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    freevm(pgdir);
80100d10:	83 ec 0c             	sub    $0xc,%esp
80100d13:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
80100d19:	e8 c2 6a 00 00       	call   801077e0 <freevm>
80100d1e:	83 c4 10             	add    $0x10,%esp
  return -1;
80100d21:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100d26:	e9 f1 fd ff ff       	jmp    80100b1c <exec+0x6c>
80100d2b:	8b b5 f0 fe ff ff    	mov    -0x110(%ebp),%esi
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d31:	8d 04 bd 04 00 00 00 	lea    0x4(,%edi,4),%eax
80100d38:	89 d9                	mov    %ebx,%ecx
  ustack[3+argc] = 0;
80100d3a:	c7 84 bd 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%edi,4)
80100d41:	00 00 00 00 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d45:	29 c1                	sub    %eax,%ecx
  sp -= (3+argc+1) * 4;
80100d47:	83 c0 0c             	add    $0xc,%eax
  ustack[1] = argc;
80100d4a:	89 bd 5c ff ff ff    	mov    %edi,-0xa4(%ebp)
  sp -= (3+argc+1) * 4;
80100d50:	29 c3                	sub    %eax,%ebx
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100d52:	50                   	push   %eax
80100d53:	52                   	push   %edx
80100d54:	53                   	push   %ebx
80100d55:	ff b5 f4 fe ff ff    	push   -0x10c(%ebp)
  ustack[0] = 0xffffffff;  // fake return PC
80100d5b:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100d62:	ff ff ff 
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100d65:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100d6b:	e8 50 6d 00 00       	call   80107ac0 <copyout>
80100d70:	83 c4 10             	add    $0x10,%esp
80100d73:	85 c0                	test   %eax,%eax
80100d75:	78 99                	js     80100d10 <exec+0x260>
  for(last=s=path; *s; s++)
80100d77:	8b 45 08             	mov    0x8(%ebp),%eax
80100d7a:	8b 55 08             	mov    0x8(%ebp),%edx
80100d7d:	0f b6 00             	movzbl (%eax),%eax
80100d80:	84 c0                	test   %al,%al
80100d82:	74 1b                	je     80100d9f <exec+0x2ef>
80100d84:	89 d1                	mov    %edx,%ecx
80100d86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100d8d:	8d 76 00             	lea    0x0(%esi),%esi
      last = s+1;
80100d90:	83 c1 01             	add    $0x1,%ecx
80100d93:	3c 2f                	cmp    $0x2f,%al
  for(last=s=path; *s; s++)
80100d95:	0f b6 01             	movzbl (%ecx),%eax
      last = s+1;
80100d98:	0f 44 d1             	cmove  %ecx,%edx
  for(last=s=path; *s; s++)
80100d9b:	84 c0                	test   %al,%al
80100d9d:	75 f1                	jne    80100d90 <exec+0x2e0>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100d9f:	8b bd ec fe ff ff    	mov    -0x114(%ebp),%edi
80100da5:	83 ec 04             	sub    $0x4,%esp
80100da8:	6a 10                	push   $0x10
80100daa:	89 f8                	mov    %edi,%eax
80100dac:	52                   	push   %edx
80100dad:	83 c0 6c             	add    $0x6c,%eax
80100db0:	50                   	push   %eax
80100db1:	e8 3a 40 00 00       	call   80104df0 <safestrcpy>
  curproc->pgdir = pgdir;
80100db6:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
  oldpgdir = curproc->pgdir;
80100dbc:	89 f8                	mov    %edi,%eax
80100dbe:	8b 7f 04             	mov    0x4(%edi),%edi
  curproc->sz = sz;
80100dc1:	89 30                	mov    %esi,(%eax)
  curproc->pgdir = pgdir;
80100dc3:	89 48 04             	mov    %ecx,0x4(%eax)
  curproc->tf->eip = elf.entry;  // main
80100dc6:	89 c1                	mov    %eax,%ecx
80100dc8:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100dce:	8b 40 18             	mov    0x18(%eax),%eax
80100dd1:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100dd4:	8b 41 18             	mov    0x18(%ecx),%eax
80100dd7:	89 58 44             	mov    %ebx,0x44(%eax)
  switchuvm(curproc);
80100dda:	89 0c 24             	mov    %ecx,(%esp)
80100ddd:	e8 0e 66 00 00       	call   801073f0 <switchuvm>
  freevm(oldpgdir);
80100de2:	89 3c 24             	mov    %edi,(%esp)
80100de5:	e8 f6 69 00 00       	call   801077e0 <freevm>
  return 0;
80100dea:	83 c4 10             	add    $0x10,%esp
80100ded:	31 c0                	xor    %eax,%eax
80100def:	e9 28 fd ff ff       	jmp    80100b1c <exec+0x6c>
    end_op();
80100df4:	e8 e7 1f 00 00       	call   80102de0 <end_op>
    cprintf("exec: fail\n");
80100df9:	83 ec 0c             	sub    $0xc,%esp
80100dfc:	68 21 7c 10 80       	push   $0x80107c21
80100e01:	e8 9a f8 ff ff       	call   801006a0 <cprintf>
    return -1;
80100e06:	83 c4 10             	add    $0x10,%esp
80100e09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100e0e:	e9 09 fd ff ff       	jmp    80100b1c <exec+0x6c>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100e13:	be 00 20 00 00       	mov    $0x2000,%esi
80100e18:	31 ff                	xor    %edi,%edi
80100e1a:	e9 31 fe ff ff       	jmp    80100c50 <exec+0x1a0>
80100e1f:	90                   	nop

80100e20 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100e20:	55                   	push   %ebp
80100e21:	89 e5                	mov    %esp,%ebp
80100e23:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100e26:	68 2d 7c 10 80       	push   $0x80107c2d
80100e2b:	68 60 ff 10 80       	push   $0x8010ff60
80100e30:	e8 6b 3b 00 00       	call   801049a0 <initlock>
}
80100e35:	83 c4 10             	add    $0x10,%esp
80100e38:	c9                   	leave  
80100e39:	c3                   	ret    
80100e3a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80100e40 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100e40:	55                   	push   %ebp
80100e41:	89 e5                	mov    %esp,%ebp
80100e43:	53                   	push   %ebx
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e44:	bb 94 ff 10 80       	mov    $0x8010ff94,%ebx
{
80100e49:	83 ec 10             	sub    $0x10,%esp
  acquire(&ftable.lock);
80100e4c:	68 60 ff 10 80       	push   $0x8010ff60
80100e51:	e8 1a 3d 00 00       	call   80104b70 <acquire>
80100e56:	83 c4 10             	add    $0x10,%esp
80100e59:	eb 10                	jmp    80100e6b <filealloc+0x2b>
80100e5b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100e5f:	90                   	nop
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100e60:	83 c3 18             	add    $0x18,%ebx
80100e63:	81 fb f4 08 11 80    	cmp    $0x801108f4,%ebx
80100e69:	74 25                	je     80100e90 <filealloc+0x50>
    if(f->ref == 0){
80100e6b:	8b 43 04             	mov    0x4(%ebx),%eax
80100e6e:	85 c0                	test   %eax,%eax
80100e70:	75 ee                	jne    80100e60 <filealloc+0x20>
      f->ref = 1;
      release(&ftable.lock);
80100e72:	83 ec 0c             	sub    $0xc,%esp
      f->ref = 1;
80100e75:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100e7c:	68 60 ff 10 80       	push   $0x8010ff60
80100e81:	e8 8a 3c 00 00       	call   80104b10 <release>
      return f;
    }
  }
  release(&ftable.lock);
  return 0;
}
80100e86:	89 d8                	mov    %ebx,%eax
      return f;
80100e88:	83 c4 10             	add    $0x10,%esp
}
80100e8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100e8e:	c9                   	leave  
80100e8f:	c3                   	ret    
  release(&ftable.lock);
80100e90:	83 ec 0c             	sub    $0xc,%esp
  return 0;
80100e93:	31 db                	xor    %ebx,%ebx
  release(&ftable.lock);
80100e95:	68 60 ff 10 80       	push   $0x8010ff60
80100e9a:	e8 71 3c 00 00       	call   80104b10 <release>
}
80100e9f:	89 d8                	mov    %ebx,%eax
  return 0;
80100ea1:	83 c4 10             	add    $0x10,%esp
}
80100ea4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ea7:	c9                   	leave  
80100ea8:	c3                   	ret    
80100ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80100eb0 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100eb0:	55                   	push   %ebp
80100eb1:	89 e5                	mov    %esp,%ebp
80100eb3:	53                   	push   %ebx
80100eb4:	83 ec 10             	sub    $0x10,%esp
80100eb7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100eba:	68 60 ff 10 80       	push   $0x8010ff60
80100ebf:	e8 ac 3c 00 00       	call   80104b70 <acquire>
  if(f->ref < 1)
80100ec4:	8b 43 04             	mov    0x4(%ebx),%eax
80100ec7:	83 c4 10             	add    $0x10,%esp
80100eca:	85 c0                	test   %eax,%eax
80100ecc:	7e 1a                	jle    80100ee8 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100ece:	83 c0 01             	add    $0x1,%eax
  release(&ftable.lock);
80100ed1:	83 ec 0c             	sub    $0xc,%esp
  f->ref++;
80100ed4:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100ed7:	68 60 ff 10 80       	push   $0x8010ff60
80100edc:	e8 2f 3c 00 00       	call   80104b10 <release>
  return f;
}
80100ee1:	89 d8                	mov    %ebx,%eax
80100ee3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ee6:	c9                   	leave  
80100ee7:	c3                   	ret    
    panic("filedup");
80100ee8:	83 ec 0c             	sub    $0xc,%esp
80100eeb:	68 34 7c 10 80       	push   $0x80107c34
80100ef0:	e8 8b f4 ff ff       	call   80100380 <panic>
80100ef5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100efc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80100f00 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100f00:	55                   	push   %ebp
80100f01:	89 e5                	mov    %esp,%ebp
80100f03:	57                   	push   %edi
80100f04:	56                   	push   %esi
80100f05:	53                   	push   %ebx
80100f06:	83 ec 28             	sub    $0x28,%esp
80100f09:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100f0c:	68 60 ff 10 80       	push   $0x8010ff60
80100f11:	e8 5a 3c 00 00       	call   80104b70 <acquire>
  if(f->ref < 1)
80100f16:	8b 53 04             	mov    0x4(%ebx),%edx
80100f19:	83 c4 10             	add    $0x10,%esp
80100f1c:	85 d2                	test   %edx,%edx
80100f1e:	0f 8e a5 00 00 00    	jle    80100fc9 <fileclose+0xc9>
    panic("fileclose");
  if(--f->ref > 0){
80100f24:	83 ea 01             	sub    $0x1,%edx
80100f27:	89 53 04             	mov    %edx,0x4(%ebx)
80100f2a:	75 44                	jne    80100f70 <fileclose+0x70>
    release(&ftable.lock);
    return;
  }
  ff = *f;
80100f2c:	0f b6 43 09          	movzbl 0x9(%ebx),%eax
  f->ref = 0;
  f->type = FD_NONE;
  release(&ftable.lock);
80100f30:	83 ec 0c             	sub    $0xc,%esp
  ff = *f;
80100f33:	8b 3b                	mov    (%ebx),%edi
  f->type = FD_NONE;
80100f35:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  ff = *f;
80100f3b:	8b 73 0c             	mov    0xc(%ebx),%esi
80100f3e:	88 45 e7             	mov    %al,-0x19(%ebp)
80100f41:	8b 43 10             	mov    0x10(%ebx),%eax
  release(&ftable.lock);
80100f44:	68 60 ff 10 80       	push   $0x8010ff60
  ff = *f;
80100f49:	89 45 e0             	mov    %eax,-0x20(%ebp)
  release(&ftable.lock);
80100f4c:	e8 bf 3b 00 00       	call   80104b10 <release>

  if(ff.type == FD_PIPE)
80100f51:	83 c4 10             	add    $0x10,%esp
80100f54:	83 ff 01             	cmp    $0x1,%edi
80100f57:	74 57                	je     80100fb0 <fileclose+0xb0>
    pipeclose(ff.pipe, ff.writable);
  else if(ff.type == FD_INODE){
80100f59:	83 ff 02             	cmp    $0x2,%edi
80100f5c:	74 2a                	je     80100f88 <fileclose+0x88>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100f5e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f61:	5b                   	pop    %ebx
80100f62:	5e                   	pop    %esi
80100f63:	5f                   	pop    %edi
80100f64:	5d                   	pop    %ebp
80100f65:	c3                   	ret    
80100f66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100f6d:	8d 76 00             	lea    0x0(%esi),%esi
    release(&ftable.lock);
80100f70:	c7 45 08 60 ff 10 80 	movl   $0x8010ff60,0x8(%ebp)
}
80100f77:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f7a:	5b                   	pop    %ebx
80100f7b:	5e                   	pop    %esi
80100f7c:	5f                   	pop    %edi
80100f7d:	5d                   	pop    %ebp
    release(&ftable.lock);
80100f7e:	e9 8d 3b 00 00       	jmp    80104b10 <release>
80100f83:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80100f87:	90                   	nop
    begin_op();
80100f88:	e8 e3 1d 00 00       	call   80102d70 <begin_op>
    iput(ff.ip);
80100f8d:	83 ec 0c             	sub    $0xc,%esp
80100f90:	ff 75 e0             	push   -0x20(%ebp)
80100f93:	e8 28 09 00 00       	call   801018c0 <iput>
    end_op();
80100f98:	83 c4 10             	add    $0x10,%esp
}
80100f9b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f9e:	5b                   	pop    %ebx
80100f9f:	5e                   	pop    %esi
80100fa0:	5f                   	pop    %edi
80100fa1:	5d                   	pop    %ebp
    end_op();
80100fa2:	e9 39 1e 00 00       	jmp    80102de0 <end_op>
80100fa7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100fae:	66 90                	xchg   %ax,%ax
    pipeclose(ff.pipe, ff.writable);
80100fb0:	0f be 5d e7          	movsbl -0x19(%ebp),%ebx
80100fb4:	83 ec 08             	sub    $0x8,%esp
80100fb7:	53                   	push   %ebx
80100fb8:	56                   	push   %esi
80100fb9:	e8 82 25 00 00       	call   80103540 <pipeclose>
80100fbe:	83 c4 10             	add    $0x10,%esp
}
80100fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fc4:	5b                   	pop    %ebx
80100fc5:	5e                   	pop    %esi
80100fc6:	5f                   	pop    %edi
80100fc7:	5d                   	pop    %ebp
80100fc8:	c3                   	ret    
    panic("fileclose");
80100fc9:	83 ec 0c             	sub    $0xc,%esp
80100fcc:	68 3c 7c 10 80       	push   $0x80107c3c
80100fd1:	e8 aa f3 ff ff       	call   80100380 <panic>
80100fd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80100fdd:	8d 76 00             	lea    0x0(%esi),%esi

80100fe0 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100fe0:	55                   	push   %ebp
80100fe1:	89 e5                	mov    %esp,%ebp
80100fe3:	53                   	push   %ebx
80100fe4:	83 ec 04             	sub    $0x4,%esp
80100fe7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100fea:	83 3b 02             	cmpl   $0x2,(%ebx)
80100fed:	75 31                	jne    80101020 <filestat+0x40>
    ilock(f->ip);
80100fef:	83 ec 0c             	sub    $0xc,%esp
80100ff2:	ff 73 10             	push   0x10(%ebx)
80100ff5:	e8 96 07 00 00       	call   80101790 <ilock>
    stati(f->ip, st);
80100ffa:	58                   	pop    %eax
80100ffb:	5a                   	pop    %edx
80100ffc:	ff 75 0c             	push   0xc(%ebp)
80100fff:	ff 73 10             	push   0x10(%ebx)
80101002:	e8 69 0a 00 00       	call   80101a70 <stati>
    iunlock(f->ip);
80101007:	59                   	pop    %ecx
80101008:	ff 73 10             	push   0x10(%ebx)
8010100b:	e8 60 08 00 00       	call   80101870 <iunlock>
    return 0;
  }
  return -1;
}
80101010:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return 0;
80101013:	83 c4 10             	add    $0x10,%esp
80101016:	31 c0                	xor    %eax,%eax
}
80101018:	c9                   	leave  
80101019:	c3                   	ret    
8010101a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80101020:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80101023:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101028:	c9                   	leave  
80101029:	c3                   	ret    
8010102a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101030 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101030:	55                   	push   %ebp
80101031:	89 e5                	mov    %esp,%ebp
80101033:	57                   	push   %edi
80101034:	56                   	push   %esi
80101035:	53                   	push   %ebx
80101036:	83 ec 0c             	sub    $0xc,%esp
80101039:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010103c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010103f:	8b 7d 10             	mov    0x10(%ebp),%edi
  int r;

  if(f->readable == 0)
80101042:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80101046:	74 60                	je     801010a8 <fileread+0x78>
    return -1;
  if(f->type == FD_PIPE)
80101048:	8b 03                	mov    (%ebx),%eax
8010104a:	83 f8 01             	cmp    $0x1,%eax
8010104d:	74 41                	je     80101090 <fileread+0x60>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
8010104f:	83 f8 02             	cmp    $0x2,%eax
80101052:	75 5b                	jne    801010af <fileread+0x7f>
    ilock(f->ip);
80101054:	83 ec 0c             	sub    $0xc,%esp
80101057:	ff 73 10             	push   0x10(%ebx)
8010105a:	e8 31 07 00 00       	call   80101790 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
8010105f:	57                   	push   %edi
80101060:	ff 73 14             	push   0x14(%ebx)
80101063:	56                   	push   %esi
80101064:	ff 73 10             	push   0x10(%ebx)
80101067:	e8 34 0a 00 00       	call   80101aa0 <readi>
8010106c:	83 c4 20             	add    $0x20,%esp
8010106f:	89 c6                	mov    %eax,%esi
80101071:	85 c0                	test   %eax,%eax
80101073:	7e 03                	jle    80101078 <fileread+0x48>
      f->off += r;
80101075:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80101078:	83 ec 0c             	sub    $0xc,%esp
8010107b:	ff 73 10             	push   0x10(%ebx)
8010107e:	e8 ed 07 00 00       	call   80101870 <iunlock>
    return r;
80101083:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80101086:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101089:	89 f0                	mov    %esi,%eax
8010108b:	5b                   	pop    %ebx
8010108c:	5e                   	pop    %esi
8010108d:	5f                   	pop    %edi
8010108e:	5d                   	pop    %ebp
8010108f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80101090:	8b 43 0c             	mov    0xc(%ebx),%eax
80101093:	89 45 08             	mov    %eax,0x8(%ebp)
}
80101096:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101099:	5b                   	pop    %ebx
8010109a:	5e                   	pop    %esi
8010109b:	5f                   	pop    %edi
8010109c:	5d                   	pop    %ebp
    return piperead(f->pipe, addr, n);
8010109d:	e9 3e 26 00 00       	jmp    801036e0 <piperead>
801010a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
801010a8:	be ff ff ff ff       	mov    $0xffffffff,%esi
801010ad:	eb d7                	jmp    80101086 <fileread+0x56>
  panic("fileread");
801010af:	83 ec 0c             	sub    $0xc,%esp
801010b2:	68 46 7c 10 80       	push   $0x80107c46
801010b7:	e8 c4 f2 ff ff       	call   80100380 <panic>
801010bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801010c0 <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
801010c0:	55                   	push   %ebp
801010c1:	89 e5                	mov    %esp,%ebp
801010c3:	57                   	push   %edi
801010c4:	56                   	push   %esi
801010c5:	53                   	push   %ebx
801010c6:	83 ec 1c             	sub    $0x1c,%esp
801010c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801010cc:	8b 5d 08             	mov    0x8(%ebp),%ebx
801010cf:	89 45 dc             	mov    %eax,-0x24(%ebp)
801010d2:	8b 45 10             	mov    0x10(%ebp),%eax
  int r;

  if(f->writable == 0)
801010d5:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
{
801010d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(f->writable == 0)
801010dc:	0f 84 bd 00 00 00    	je     8010119f <filewrite+0xdf>
    return -1;
  if(f->type == FD_PIPE)
801010e2:	8b 03                	mov    (%ebx),%eax
801010e4:	83 f8 01             	cmp    $0x1,%eax
801010e7:	0f 84 bf 00 00 00    	je     801011ac <filewrite+0xec>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
801010ed:	83 f8 02             	cmp    $0x2,%eax
801010f0:	0f 85 c8 00 00 00    	jne    801011be <filewrite+0xfe>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
801010f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
    int i = 0;
801010f9:	31 f6                	xor    %esi,%esi
    while(i < n){
801010fb:	85 c0                	test   %eax,%eax
801010fd:	7f 30                	jg     8010112f <filewrite+0x6f>
801010ff:	e9 94 00 00 00       	jmp    80101198 <filewrite+0xd8>
80101104:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
        n1 = max;

      begin_op();
      ilock(f->ip);
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
        f->off += r;
80101108:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	ff 73 10             	push   0x10(%ebx)
        f->off += r;
80101111:	89 45 e0             	mov    %eax,-0x20(%ebp)
      iunlock(f->ip);
80101114:	e8 57 07 00 00       	call   80101870 <iunlock>
      end_op();
80101119:	e8 c2 1c 00 00       	call   80102de0 <end_op>

      if(r < 0)
        break;
      if(r != n1)
8010111e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80101121:	83 c4 10             	add    $0x10,%esp
80101124:	39 c7                	cmp    %eax,%edi
80101126:	75 5c                	jne    80101184 <filewrite+0xc4>
        panic("short filewrite");
      i += r;
80101128:	01 fe                	add    %edi,%esi
    while(i < n){
8010112a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
8010112d:	7e 69                	jle    80101198 <filewrite+0xd8>
      int n1 = n - i;
8010112f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101132:	b8 00 06 00 00       	mov    $0x600,%eax
80101137:	29 f7                	sub    %esi,%edi
80101139:	39 c7                	cmp    %eax,%edi
8010113b:	0f 4f f8             	cmovg  %eax,%edi
      begin_op();
8010113e:	e8 2d 1c 00 00       	call   80102d70 <begin_op>
      ilock(f->ip);
80101143:	83 ec 0c             	sub    $0xc,%esp
80101146:	ff 73 10             	push   0x10(%ebx)
80101149:	e8 42 06 00 00       	call   80101790 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
8010114e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101151:	57                   	push   %edi
80101152:	ff 73 14             	push   0x14(%ebx)
80101155:	01 f0                	add    %esi,%eax
80101157:	50                   	push   %eax
80101158:	ff 73 10             	push   0x10(%ebx)
8010115b:	e8 40 0a 00 00       	call   80101ba0 <writei>
80101160:	83 c4 20             	add    $0x20,%esp
80101163:	85 c0                	test   %eax,%eax
80101165:	7f a1                	jg     80101108 <filewrite+0x48>
      iunlock(f->ip);
80101167:	83 ec 0c             	sub    $0xc,%esp
8010116a:	ff 73 10             	push   0x10(%ebx)
8010116d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101170:	e8 fb 06 00 00       	call   80101870 <iunlock>
      end_op();
80101175:	e8 66 1c 00 00       	call   80102de0 <end_op>
      if(r < 0)
8010117a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010117d:	83 c4 10             	add    $0x10,%esp
80101180:	85 c0                	test   %eax,%eax
80101182:	75 1b                	jne    8010119f <filewrite+0xdf>
        panic("short filewrite");
80101184:	83 ec 0c             	sub    $0xc,%esp
80101187:	68 4f 7c 10 80       	push   $0x80107c4f
8010118c:	e8 ef f1 ff ff       	call   80100380 <panic>
80101191:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    }
    return i == n ? n : -1;
80101198:	89 f0                	mov    %esi,%eax
8010119a:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
8010119d:	74 05                	je     801011a4 <filewrite+0xe4>
8010119f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  panic("filewrite");
}
801011a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011a7:	5b                   	pop    %ebx
801011a8:	5e                   	pop    %esi
801011a9:	5f                   	pop    %edi
801011aa:	5d                   	pop    %ebp
801011ab:	c3                   	ret    
    return pipewrite(f->pipe, addr, n);
801011ac:	8b 43 0c             	mov    0xc(%ebx),%eax
801011af:	89 45 08             	mov    %eax,0x8(%ebp)
}
801011b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801011b5:	5b                   	pop    %ebx
801011b6:	5e                   	pop    %esi
801011b7:	5f                   	pop    %edi
801011b8:	5d                   	pop    %ebp
    return pipewrite(f->pipe, addr, n);
801011b9:	e9 22 24 00 00       	jmp    801035e0 <pipewrite>
  panic("filewrite");
801011be:	83 ec 0c             	sub    $0xc,%esp
801011c1:	68 55 7c 10 80       	push   $0x80107c55
801011c6:	e8 b5 f1 ff ff       	call   80100380 <panic>
801011cb:	66 90                	xchg   %ax,%ax
801011cd:	66 90                	xchg   %ax,%ax
801011cf:	90                   	nop

801011d0 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
801011d0:	55                   	push   %ebp
801011d1:	89 c1                	mov    %eax,%ecx
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
801011d3:	89 d0                	mov    %edx,%eax
801011d5:	c1 e8 0c             	shr    $0xc,%eax
801011d8:	03 05 cc 25 11 80    	add    0x801125cc,%eax
{
801011de:	89 e5                	mov    %esp,%ebp
801011e0:	56                   	push   %esi
801011e1:	53                   	push   %ebx
801011e2:	89 d3                	mov    %edx,%ebx
  bp = bread(dev, BBLOCK(b, sb));
801011e4:	83 ec 08             	sub    $0x8,%esp
801011e7:	50                   	push   %eax
801011e8:	51                   	push   %ecx
801011e9:	e8 e2 ee ff ff       	call   801000d0 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
801011ee:	89 d9                	mov    %ebx,%ecx
  if((bp->data[bi/8] & m) == 0)
801011f0:	c1 fb 03             	sar    $0x3,%ebx
801011f3:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
801011f6:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
801011f8:	83 e1 07             	and    $0x7,%ecx
801011fb:	b8 01 00 00 00       	mov    $0x1,%eax
  if((bp->data[bi/8] & m) == 0)
80101200:	81 e3 ff 01 00 00    	and    $0x1ff,%ebx
  m = 1 << (bi % 8);
80101206:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
80101208:	0f b6 4c 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%ecx
8010120d:	85 c1                	test   %eax,%ecx
8010120f:	74 23                	je     80101234 <bfree+0x64>
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
80101211:	f7 d0                	not    %eax
  log_write(bp);
80101213:	83 ec 0c             	sub    $0xc,%esp
  bp->data[bi/8] &= ~m;
80101216:	21 c8                	and    %ecx,%eax
80101218:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
8010121c:	56                   	push   %esi
8010121d:	e8 2e 1d 00 00       	call   80102f50 <log_write>
  brelse(bp);
80101222:	89 34 24             	mov    %esi,(%esp)
80101225:	e8 c6 ef ff ff       	call   801001f0 <brelse>
}
8010122a:	83 c4 10             	add    $0x10,%esp
8010122d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101230:	5b                   	pop    %ebx
80101231:	5e                   	pop    %esi
80101232:	5d                   	pop    %ebp
80101233:	c3                   	ret    
    panic("freeing free block");
80101234:	83 ec 0c             	sub    $0xc,%esp
80101237:	68 5f 7c 10 80       	push   $0x80107c5f
8010123c:	e8 3f f1 ff ff       	call   80100380 <panic>
80101241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101248:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010124f:	90                   	nop

80101250 <balloc>:
{
80101250:	55                   	push   %ebp
80101251:	89 e5                	mov    %esp,%ebp
80101253:	57                   	push   %edi
80101254:	56                   	push   %esi
80101255:	53                   	push   %ebx
80101256:	83 ec 1c             	sub    $0x1c,%esp
  for(b = 0; b < sb.size; b += BPB){
80101259:	8b 0d b4 25 11 80    	mov    0x801125b4,%ecx
{
8010125f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101262:	85 c9                	test   %ecx,%ecx
80101264:	0f 84 87 00 00 00    	je     801012f1 <balloc+0xa1>
8010126a:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
    bp = bread(dev, BBLOCK(b, sb));
80101271:	8b 75 dc             	mov    -0x24(%ebp),%esi
80101274:	83 ec 08             	sub    $0x8,%esp
80101277:	89 f0                	mov    %esi,%eax
80101279:	c1 f8 0c             	sar    $0xc,%eax
8010127c:	03 05 cc 25 11 80    	add    0x801125cc,%eax
80101282:	50                   	push   %eax
80101283:	ff 75 d8             	push   -0x28(%ebp)
80101286:	e8 45 ee ff ff       	call   801000d0 <bread>
8010128b:	83 c4 10             	add    $0x10,%esp
8010128e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101291:	a1 b4 25 11 80       	mov    0x801125b4,%eax
80101296:	89 45 e0             	mov    %eax,-0x20(%ebp)
80101299:	31 c0                	xor    %eax,%eax
8010129b:	eb 2f                	jmp    801012cc <balloc+0x7c>
8010129d:	8d 76 00             	lea    0x0(%esi),%esi
      m = 1 << (bi % 8);
801012a0:	89 c1                	mov    %eax,%ecx
801012a2:	bb 01 00 00 00       	mov    $0x1,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801012a7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      m = 1 << (bi % 8);
801012aa:	83 e1 07             	and    $0x7,%ecx
801012ad:	d3 e3                	shl    %cl,%ebx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
801012af:	89 c1                	mov    %eax,%ecx
801012b1:	c1 f9 03             	sar    $0x3,%ecx
801012b4:	0f b6 7c 0a 5c       	movzbl 0x5c(%edx,%ecx,1),%edi
801012b9:	89 fa                	mov    %edi,%edx
801012bb:	85 df                	test   %ebx,%edi
801012bd:	74 41                	je     80101300 <balloc+0xb0>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801012bf:	83 c0 01             	add    $0x1,%eax
801012c2:	83 c6 01             	add    $0x1,%esi
801012c5:	3d 00 10 00 00       	cmp    $0x1000,%eax
801012ca:	74 05                	je     801012d1 <balloc+0x81>
801012cc:	39 75 e0             	cmp    %esi,-0x20(%ebp)
801012cf:	77 cf                	ja     801012a0 <balloc+0x50>
    brelse(bp);
801012d1:	83 ec 0c             	sub    $0xc,%esp
801012d4:	ff 75 e4             	push   -0x1c(%ebp)
801012d7:	e8 14 ef ff ff       	call   801001f0 <brelse>
  for(b = 0; b < sb.size; b += BPB){
801012dc:	81 45 dc 00 10 00 00 	addl   $0x1000,-0x24(%ebp)
801012e3:	83 c4 10             	add    $0x10,%esp
801012e6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801012e9:	39 05 b4 25 11 80    	cmp    %eax,0x801125b4
801012ef:	77 80                	ja     80101271 <balloc+0x21>
  panic("balloc: out of blocks");
801012f1:	83 ec 0c             	sub    $0xc,%esp
801012f4:	68 72 7c 10 80       	push   $0x80107c72
801012f9:	e8 82 f0 ff ff       	call   80100380 <panic>
801012fe:	66 90                	xchg   %ax,%ax
        bp->data[bi/8] |= m;  // Mark block in use.
80101300:	8b 7d e4             	mov    -0x1c(%ebp),%edi
        log_write(bp);
80101303:	83 ec 0c             	sub    $0xc,%esp
        bp->data[bi/8] |= m;  // Mark block in use.
80101306:	09 da                	or     %ebx,%edx
80101308:	88 54 0f 5c          	mov    %dl,0x5c(%edi,%ecx,1)
        log_write(bp);
8010130c:	57                   	push   %edi
8010130d:	e8 3e 1c 00 00       	call   80102f50 <log_write>
        brelse(bp);
80101312:	89 3c 24             	mov    %edi,(%esp)
80101315:	e8 d6 ee ff ff       	call   801001f0 <brelse>
  bp = bread(dev, bno);
8010131a:	58                   	pop    %eax
8010131b:	5a                   	pop    %edx
8010131c:	56                   	push   %esi
8010131d:	ff 75 d8             	push   -0x28(%ebp)
80101320:	e8 ab ed ff ff       	call   801000d0 <bread>
  memset(bp->data, 0, BSIZE);
80101325:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, bno);
80101328:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
8010132a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010132d:	68 00 02 00 00       	push   $0x200
80101332:	6a 00                	push   $0x0
80101334:	50                   	push   %eax
80101335:	e8 f6 38 00 00       	call   80104c30 <memset>
  log_write(bp);
8010133a:	89 1c 24             	mov    %ebx,(%esp)
8010133d:	e8 0e 1c 00 00       	call   80102f50 <log_write>
  brelse(bp);
80101342:	89 1c 24             	mov    %ebx,(%esp)
80101345:	e8 a6 ee ff ff       	call   801001f0 <brelse>
}
8010134a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010134d:	89 f0                	mov    %esi,%eax
8010134f:	5b                   	pop    %ebx
80101350:	5e                   	pop    %esi
80101351:	5f                   	pop    %edi
80101352:	5d                   	pop    %ebp
80101353:	c3                   	ret    
80101354:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010135b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010135f:	90                   	nop

80101360 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101360:	55                   	push   %ebp
80101361:	89 e5                	mov    %esp,%ebp
80101363:	57                   	push   %edi
80101364:	89 c7                	mov    %eax,%edi
80101366:	56                   	push   %esi
  struct inode *ip, *empty;

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
80101367:	31 f6                	xor    %esi,%esi
{
80101369:	53                   	push   %ebx
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010136a:	bb 94 09 11 80       	mov    $0x80110994,%ebx
{
8010136f:	83 ec 28             	sub    $0x28,%esp
80101372:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101375:	68 60 09 11 80       	push   $0x80110960
8010137a:	e8 f1 37 00 00       	call   80104b70 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010137f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  acquire(&icache.lock);
80101382:	83 c4 10             	add    $0x10,%esp
80101385:	eb 1b                	jmp    801013a2 <iget+0x42>
80101387:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010138e:	66 90                	xchg   %ax,%ax
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101390:	39 3b                	cmp    %edi,(%ebx)
80101392:	74 6c                	je     80101400 <iget+0xa0>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101394:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010139a:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
801013a0:	73 26                	jae    801013c8 <iget+0x68>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801013a2:	8b 43 08             	mov    0x8(%ebx),%eax
801013a5:	85 c0                	test   %eax,%eax
801013a7:	7f e7                	jg     80101390 <iget+0x30>
      ip->ref++;
      release(&icache.lock);
      return ip;
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801013a9:	85 f6                	test   %esi,%esi
801013ab:	75 e7                	jne    80101394 <iget+0x34>
801013ad:	85 c0                	test   %eax,%eax
801013af:	75 76                	jne    80101427 <iget+0xc7>
801013b1:	89 de                	mov    %ebx,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801013b3:	81 c3 90 00 00 00    	add    $0x90,%ebx
801013b9:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
801013bf:	72 e1                	jb     801013a2 <iget+0x42>
801013c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801013c8:	85 f6                	test   %esi,%esi
801013ca:	74 79                	je     80101445 <iget+0xe5>
  ip = empty;
  ip->dev = dev;
  ip->inum = inum;
  ip->ref = 1;
  ip->valid = 0;
  release(&icache.lock);
801013cc:	83 ec 0c             	sub    $0xc,%esp
  ip->dev = dev;
801013cf:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801013d1:	89 56 04             	mov    %edx,0x4(%esi)
  ip->ref = 1;
801013d4:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
801013db:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
801013e2:	68 60 09 11 80       	push   $0x80110960
801013e7:	e8 24 37 00 00       	call   80104b10 <release>

  return ip;
801013ec:	83 c4 10             	add    $0x10,%esp
}
801013ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
801013f2:	89 f0                	mov    %esi,%eax
801013f4:	5b                   	pop    %ebx
801013f5:	5e                   	pop    %esi
801013f6:	5f                   	pop    %edi
801013f7:	5d                   	pop    %ebp
801013f8:	c3                   	ret    
801013f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101400:	39 53 04             	cmp    %edx,0x4(%ebx)
80101403:	75 8f                	jne    80101394 <iget+0x34>
      release(&icache.lock);
80101405:	83 ec 0c             	sub    $0xc,%esp
      ip->ref++;
80101408:	83 c0 01             	add    $0x1,%eax
      return ip;
8010140b:	89 de                	mov    %ebx,%esi
      release(&icache.lock);
8010140d:	68 60 09 11 80       	push   $0x80110960
      ip->ref++;
80101412:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
80101415:	e8 f6 36 00 00       	call   80104b10 <release>
      return ip;
8010141a:	83 c4 10             	add    $0x10,%esp
}
8010141d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101420:	89 f0                	mov    %esi,%eax
80101422:	5b                   	pop    %ebx
80101423:	5e                   	pop    %esi
80101424:	5f                   	pop    %edi
80101425:	5d                   	pop    %ebp
80101426:	c3                   	ret    
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101427:	81 c3 90 00 00 00    	add    $0x90,%ebx
8010142d:	81 fb b4 25 11 80    	cmp    $0x801125b4,%ebx
80101433:	73 10                	jae    80101445 <iget+0xe5>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
80101435:	8b 43 08             	mov    0x8(%ebx),%eax
80101438:	85 c0                	test   %eax,%eax
8010143a:	0f 8f 50 ff ff ff    	jg     80101390 <iget+0x30>
80101440:	e9 68 ff ff ff       	jmp    801013ad <iget+0x4d>
    panic("iget: no inodes");
80101445:	83 ec 0c             	sub    $0xc,%esp
80101448:	68 88 7c 10 80       	push   $0x80107c88
8010144d:	e8 2e ef ff ff       	call   80100380 <panic>
80101452:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101459:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101460 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101460:	55                   	push   %ebp
80101461:	89 e5                	mov    %esp,%ebp
80101463:	57                   	push   %edi
80101464:	56                   	push   %esi
80101465:	89 c6                	mov    %eax,%esi
80101467:	53                   	push   %ebx
80101468:	83 ec 1c             	sub    $0x1c,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
8010146b:	83 fa 0b             	cmp    $0xb,%edx
8010146e:	0f 86 8c 00 00 00    	jbe    80101500 <bmap+0xa0>
    if((addr = ip->addrs[bn]) == 0)
      ip->addrs[bn] = addr = balloc(ip->dev);
    return addr;
  }
  bn -= NDIRECT;
80101474:	8d 5a f4             	lea    -0xc(%edx),%ebx

  if(bn < NINDIRECT){
80101477:	83 fb 7f             	cmp    $0x7f,%ebx
8010147a:	0f 87 a2 00 00 00    	ja     80101522 <bmap+0xc2>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101480:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101486:	85 c0                	test   %eax,%eax
80101488:	74 5e                	je     801014e8 <bmap+0x88>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
    bp = bread(ip->dev, addr);
8010148a:	83 ec 08             	sub    $0x8,%esp
8010148d:	50                   	push   %eax
8010148e:	ff 36                	push   (%esi)
80101490:	e8 3b ec ff ff       	call   801000d0 <bread>
    a = (uint*)bp->data;
    if((addr = a[bn]) == 0){
80101495:	83 c4 10             	add    $0x10,%esp
80101498:	8d 5c 98 5c          	lea    0x5c(%eax,%ebx,4),%ebx
    bp = bread(ip->dev, addr);
8010149c:	89 c2                	mov    %eax,%edx
    if((addr = a[bn]) == 0){
8010149e:	8b 3b                	mov    (%ebx),%edi
801014a0:	85 ff                	test   %edi,%edi
801014a2:	74 1c                	je     801014c0 <bmap+0x60>
      a[bn] = addr = balloc(ip->dev);
      log_write(bp);
    }
    brelse(bp);
801014a4:	83 ec 0c             	sub    $0xc,%esp
801014a7:	52                   	push   %edx
801014a8:	e8 43 ed ff ff       	call   801001f0 <brelse>
801014ad:	83 c4 10             	add    $0x10,%esp
    return addr;
  }

  panic("bmap: out of range");
}
801014b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014b3:	89 f8                	mov    %edi,%eax
801014b5:	5b                   	pop    %ebx
801014b6:	5e                   	pop    %esi
801014b7:	5f                   	pop    %edi
801014b8:	5d                   	pop    %ebp
801014b9:	c3                   	ret    
801014ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
801014c0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      a[bn] = addr = balloc(ip->dev);
801014c3:	8b 06                	mov    (%esi),%eax
801014c5:	e8 86 fd ff ff       	call   80101250 <balloc>
      log_write(bp);
801014ca:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014cd:	83 ec 0c             	sub    $0xc,%esp
      a[bn] = addr = balloc(ip->dev);
801014d0:	89 03                	mov    %eax,(%ebx)
801014d2:	89 c7                	mov    %eax,%edi
      log_write(bp);
801014d4:	52                   	push   %edx
801014d5:	e8 76 1a 00 00       	call   80102f50 <log_write>
801014da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801014dd:	83 c4 10             	add    $0x10,%esp
801014e0:	eb c2                	jmp    801014a4 <bmap+0x44>
801014e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
801014e8:	8b 06                	mov    (%esi),%eax
801014ea:	e8 61 fd ff ff       	call   80101250 <balloc>
801014ef:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
801014f5:	eb 93                	jmp    8010148a <bmap+0x2a>
801014f7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801014fe:	66 90                	xchg   %ax,%ax
    if((addr = ip->addrs[bn]) == 0)
80101500:	8d 5a 14             	lea    0x14(%edx),%ebx
80101503:	8b 7c 98 0c          	mov    0xc(%eax,%ebx,4),%edi
80101507:	85 ff                	test   %edi,%edi
80101509:	75 a5                	jne    801014b0 <bmap+0x50>
      ip->addrs[bn] = addr = balloc(ip->dev);
8010150b:	8b 00                	mov    (%eax),%eax
8010150d:	e8 3e fd ff ff       	call   80101250 <balloc>
80101512:	89 44 9e 0c          	mov    %eax,0xc(%esi,%ebx,4)
80101516:	89 c7                	mov    %eax,%edi
}
80101518:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010151b:	5b                   	pop    %ebx
8010151c:	89 f8                	mov    %edi,%eax
8010151e:	5e                   	pop    %esi
8010151f:	5f                   	pop    %edi
80101520:	5d                   	pop    %ebp
80101521:	c3                   	ret    
  panic("bmap: out of range");
80101522:	83 ec 0c             	sub    $0xc,%esp
80101525:	68 98 7c 10 80       	push   $0x80107c98
8010152a:	e8 51 ee ff ff       	call   80100380 <panic>
8010152f:	90                   	nop

80101530 <readsb>:
{
80101530:	55                   	push   %ebp
80101531:	89 e5                	mov    %esp,%ebp
80101533:	56                   	push   %esi
80101534:	53                   	push   %ebx
80101535:	8b 75 0c             	mov    0xc(%ebp),%esi
  bp = bread(dev, 1);
80101538:	83 ec 08             	sub    $0x8,%esp
8010153b:	6a 01                	push   $0x1
8010153d:	ff 75 08             	push   0x8(%ebp)
80101540:	e8 8b eb ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
80101545:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
80101548:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
8010154a:	8d 40 5c             	lea    0x5c(%eax),%eax
8010154d:	6a 1c                	push   $0x1c
8010154f:	50                   	push   %eax
80101550:	56                   	push   %esi
80101551:	e8 7a 37 00 00       	call   80104cd0 <memmove>
  brelse(bp);
80101556:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101559:	83 c4 10             	add    $0x10,%esp
}
8010155c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010155f:	5b                   	pop    %ebx
80101560:	5e                   	pop    %esi
80101561:	5d                   	pop    %ebp
  brelse(bp);
80101562:	e9 89 ec ff ff       	jmp    801001f0 <brelse>
80101567:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010156e:	66 90                	xchg   %ax,%ax

80101570 <iinit>:
{
80101570:	55                   	push   %ebp
80101571:	89 e5                	mov    %esp,%ebp
80101573:	53                   	push   %ebx
80101574:	bb a0 09 11 80       	mov    $0x801109a0,%ebx
80101579:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
8010157c:	68 ab 7c 10 80       	push   $0x80107cab
80101581:	68 60 09 11 80       	push   $0x80110960
80101586:	e8 15 34 00 00       	call   801049a0 <initlock>
  for(i = 0; i < NINODE; i++) {
8010158b:	83 c4 10             	add    $0x10,%esp
8010158e:	66 90                	xchg   %ax,%ax
    initsleeplock(&icache.inode[i].lock, "inode");
80101590:	83 ec 08             	sub    $0x8,%esp
80101593:	68 b2 7c 10 80       	push   $0x80107cb2
80101598:	53                   	push   %ebx
  for(i = 0; i < NINODE; i++) {
80101599:	81 c3 90 00 00 00    	add    $0x90,%ebx
    initsleeplock(&icache.inode[i].lock, "inode");
8010159f:	e8 cc 32 00 00       	call   80104870 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
801015a4:	83 c4 10             	add    $0x10,%esp
801015a7:	81 fb c0 25 11 80    	cmp    $0x801125c0,%ebx
801015ad:	75 e1                	jne    80101590 <iinit+0x20>
  bp = bread(dev, 1);
801015af:	83 ec 08             	sub    $0x8,%esp
801015b2:	6a 01                	push   $0x1
801015b4:	ff 75 08             	push   0x8(%ebp)
801015b7:	e8 14 eb ff ff       	call   801000d0 <bread>
  memmove(sb, bp->data, sizeof(*sb));
801015bc:	83 c4 0c             	add    $0xc,%esp
  bp = bread(dev, 1);
801015bf:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
801015c1:	8d 40 5c             	lea    0x5c(%eax),%eax
801015c4:	6a 1c                	push   $0x1c
801015c6:	50                   	push   %eax
801015c7:	68 b4 25 11 80       	push   $0x801125b4
801015cc:	e8 ff 36 00 00       	call   80104cd0 <memmove>
  brelse(bp);
801015d1:	89 1c 24             	mov    %ebx,(%esp)
801015d4:	e8 17 ec ff ff       	call   801001f0 <brelse>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
801015d9:	ff 35 cc 25 11 80    	push   0x801125cc
801015df:	ff 35 c8 25 11 80    	push   0x801125c8
801015e5:	ff 35 c4 25 11 80    	push   0x801125c4
801015eb:	ff 35 c0 25 11 80    	push   0x801125c0
801015f1:	ff 35 bc 25 11 80    	push   0x801125bc
801015f7:	ff 35 b8 25 11 80    	push   0x801125b8
801015fd:	ff 35 b4 25 11 80    	push   0x801125b4
80101603:	68 18 7d 10 80       	push   $0x80107d18
80101608:	e8 93 f0 ff ff       	call   801006a0 <cprintf>
}
8010160d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101610:	83 c4 30             	add    $0x30,%esp
80101613:	c9                   	leave  
80101614:	c3                   	ret    
80101615:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010161c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101620 <ialloc>:
{
80101620:	55                   	push   %ebp
80101621:	89 e5                	mov    %esp,%ebp
80101623:	57                   	push   %edi
80101624:	56                   	push   %esi
80101625:	53                   	push   %ebx
80101626:	83 ec 1c             	sub    $0x1c,%esp
80101629:	8b 45 0c             	mov    0xc(%ebp),%eax
  for(inum = 1; inum < sb.ninodes; inum++){
8010162c:	83 3d bc 25 11 80 01 	cmpl   $0x1,0x801125bc
{
80101633:	8b 75 08             	mov    0x8(%ebp),%esi
80101636:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
80101639:	0f 86 91 00 00 00    	jbe    801016d0 <ialloc+0xb0>
8010163f:	bf 01 00 00 00       	mov    $0x1,%edi
80101644:	eb 21                	jmp    80101667 <ialloc+0x47>
80101646:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010164d:	8d 76 00             	lea    0x0(%esi),%esi
    brelse(bp);
80101650:	83 ec 0c             	sub    $0xc,%esp
  for(inum = 1; inum < sb.ninodes; inum++){
80101653:	83 c7 01             	add    $0x1,%edi
    brelse(bp);
80101656:	53                   	push   %ebx
80101657:	e8 94 eb ff ff       	call   801001f0 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
8010165c:	83 c4 10             	add    $0x10,%esp
8010165f:	3b 3d bc 25 11 80    	cmp    0x801125bc,%edi
80101665:	73 69                	jae    801016d0 <ialloc+0xb0>
    bp = bread(dev, IBLOCK(inum, sb));
80101667:	89 f8                	mov    %edi,%eax
80101669:	83 ec 08             	sub    $0x8,%esp
8010166c:	c1 e8 03             	shr    $0x3,%eax
8010166f:	03 05 c8 25 11 80    	add    0x801125c8,%eax
80101675:	50                   	push   %eax
80101676:	56                   	push   %esi
80101677:	e8 54 ea ff ff       	call   801000d0 <bread>
    if(dip->type == 0){  // a free inode
8010167c:	83 c4 10             	add    $0x10,%esp
    bp = bread(dev, IBLOCK(inum, sb));
8010167f:	89 c3                	mov    %eax,%ebx
    dip = (struct dinode*)bp->data + inum%IPB;
80101681:	89 f8                	mov    %edi,%eax
80101683:	83 e0 07             	and    $0x7,%eax
80101686:	c1 e0 06             	shl    $0x6,%eax
80101689:	8d 4c 03 5c          	lea    0x5c(%ebx,%eax,1),%ecx
    if(dip->type == 0){  // a free inode
8010168d:	66 83 39 00          	cmpw   $0x0,(%ecx)
80101691:	75 bd                	jne    80101650 <ialloc+0x30>
      memset(dip, 0, sizeof(*dip));
80101693:	83 ec 04             	sub    $0x4,%esp
80101696:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80101699:	6a 40                	push   $0x40
8010169b:	6a 00                	push   $0x0
8010169d:	51                   	push   %ecx
8010169e:	e8 8d 35 00 00       	call   80104c30 <memset>
      dip->type = type;
801016a3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
801016a7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
801016aa:	66 89 01             	mov    %ax,(%ecx)
      log_write(bp);   // mark it allocated on the disk
801016ad:	89 1c 24             	mov    %ebx,(%esp)
801016b0:	e8 9b 18 00 00       	call   80102f50 <log_write>
      brelse(bp);
801016b5:	89 1c 24             	mov    %ebx,(%esp)
801016b8:	e8 33 eb ff ff       	call   801001f0 <brelse>
      return iget(dev, inum);
801016bd:	83 c4 10             	add    $0x10,%esp
}
801016c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return iget(dev, inum);
801016c3:	89 fa                	mov    %edi,%edx
}
801016c5:	5b                   	pop    %ebx
      return iget(dev, inum);
801016c6:	89 f0                	mov    %esi,%eax
}
801016c8:	5e                   	pop    %esi
801016c9:	5f                   	pop    %edi
801016ca:	5d                   	pop    %ebp
      return iget(dev, inum);
801016cb:	e9 90 fc ff ff       	jmp    80101360 <iget>
  panic("ialloc: no inodes");
801016d0:	83 ec 0c             	sub    $0xc,%esp
801016d3:	68 b8 7c 10 80       	push   $0x80107cb8
801016d8:	e8 a3 ec ff ff       	call   80100380 <panic>
801016dd:	8d 76 00             	lea    0x0(%esi),%esi

801016e0 <iupdate>:
{
801016e0:	55                   	push   %ebp
801016e1:	89 e5                	mov    %esp,%ebp
801016e3:	56                   	push   %esi
801016e4:	53                   	push   %ebx
801016e5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016e8:	8b 43 04             	mov    0x4(%ebx),%eax
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801016eb:	83 c3 5c             	add    $0x5c,%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801016ee:	83 ec 08             	sub    $0x8,%esp
801016f1:	c1 e8 03             	shr    $0x3,%eax
801016f4:	03 05 c8 25 11 80    	add    0x801125c8,%eax
801016fa:	50                   	push   %eax
801016fb:	ff 73 a4             	push   -0x5c(%ebx)
801016fe:	e8 cd e9 ff ff       	call   801000d0 <bread>
  dip->type = ip->type;
80101703:	0f b7 53 f4          	movzwl -0xc(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101707:	83 c4 0c             	add    $0xc,%esp
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010170a:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
8010170c:	8b 43 a8             	mov    -0x58(%ebx),%eax
8010170f:	83 e0 07             	and    $0x7,%eax
80101712:	c1 e0 06             	shl    $0x6,%eax
80101715:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
80101719:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
8010171c:	0f b7 53 f6          	movzwl -0xa(%ebx),%edx
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101720:	83 c0 0c             	add    $0xc,%eax
  dip->major = ip->major;
80101723:	66 89 50 f6          	mov    %dx,-0xa(%eax)
  dip->minor = ip->minor;
80101727:	0f b7 53 f8          	movzwl -0x8(%ebx),%edx
8010172b:	66 89 50 f8          	mov    %dx,-0x8(%eax)
  dip->nlink = ip->nlink;
8010172f:	0f b7 53 fa          	movzwl -0x6(%ebx),%edx
80101733:	66 89 50 fa          	mov    %dx,-0x6(%eax)
  dip->size = ip->size;
80101737:	8b 53 fc             	mov    -0x4(%ebx),%edx
8010173a:	89 50 fc             	mov    %edx,-0x4(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
8010173d:	6a 34                	push   $0x34
8010173f:	53                   	push   %ebx
80101740:	50                   	push   %eax
80101741:	e8 8a 35 00 00       	call   80104cd0 <memmove>
  log_write(bp);
80101746:	89 34 24             	mov    %esi,(%esp)
80101749:	e8 02 18 00 00       	call   80102f50 <log_write>
  brelse(bp);
8010174e:	89 75 08             	mov    %esi,0x8(%ebp)
80101751:	83 c4 10             	add    $0x10,%esp
}
80101754:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101757:	5b                   	pop    %ebx
80101758:	5e                   	pop    %esi
80101759:	5d                   	pop    %ebp
  brelse(bp);
8010175a:	e9 91 ea ff ff       	jmp    801001f0 <brelse>
8010175f:	90                   	nop

80101760 <idup>:
{
80101760:	55                   	push   %ebp
80101761:	89 e5                	mov    %esp,%ebp
80101763:	53                   	push   %ebx
80101764:	83 ec 10             	sub    $0x10,%esp
80101767:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010176a:	68 60 09 11 80       	push   $0x80110960
8010176f:	e8 fc 33 00 00       	call   80104b70 <acquire>
  ip->ref++;
80101774:	83 43 08 01          	addl   $0x1,0x8(%ebx)
  release(&icache.lock);
80101778:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
8010177f:	e8 8c 33 00 00       	call   80104b10 <release>
}
80101784:	89 d8                	mov    %ebx,%eax
80101786:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101789:	c9                   	leave  
8010178a:	c3                   	ret    
8010178b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010178f:	90                   	nop

80101790 <ilock>:
{
80101790:	55                   	push   %ebp
80101791:	89 e5                	mov    %esp,%ebp
80101793:	56                   	push   %esi
80101794:	53                   	push   %ebx
80101795:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101798:	85 db                	test   %ebx,%ebx
8010179a:	0f 84 b7 00 00 00    	je     80101857 <ilock+0xc7>
801017a0:	8b 53 08             	mov    0x8(%ebx),%edx
801017a3:	85 d2                	test   %edx,%edx
801017a5:	0f 8e ac 00 00 00    	jle    80101857 <ilock+0xc7>
  acquiresleep(&ip->lock);
801017ab:	83 ec 0c             	sub    $0xc,%esp
801017ae:	8d 43 0c             	lea    0xc(%ebx),%eax
801017b1:	50                   	push   %eax
801017b2:	e8 f9 30 00 00       	call   801048b0 <acquiresleep>
  if(ip->valid == 0){
801017b7:	8b 43 4c             	mov    0x4c(%ebx),%eax
801017ba:	83 c4 10             	add    $0x10,%esp
801017bd:	85 c0                	test   %eax,%eax
801017bf:	74 0f                	je     801017d0 <ilock+0x40>
}
801017c1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801017c4:	5b                   	pop    %ebx
801017c5:	5e                   	pop    %esi
801017c6:	5d                   	pop    %ebp
801017c7:	c3                   	ret    
801017c8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801017cf:	90                   	nop
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017d0:	8b 43 04             	mov    0x4(%ebx),%eax
801017d3:	83 ec 08             	sub    $0x8,%esp
801017d6:	c1 e8 03             	shr    $0x3,%eax
801017d9:	03 05 c8 25 11 80    	add    0x801125c8,%eax
801017df:	50                   	push   %eax
801017e0:	ff 33                	push   (%ebx)
801017e2:	e8 e9 e8 ff ff       	call   801000d0 <bread>
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017e7:	83 c4 0c             	add    $0xc,%esp
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801017ea:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801017ec:	8b 43 04             	mov    0x4(%ebx),%eax
801017ef:	83 e0 07             	and    $0x7,%eax
801017f2:	c1 e0 06             	shl    $0x6,%eax
801017f5:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801017f9:	0f b7 10             	movzwl (%eax),%edx
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
801017fc:	83 c0 0c             	add    $0xc,%eax
    ip->type = dip->type;
801017ff:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
80101803:	0f b7 50 f6          	movzwl -0xa(%eax),%edx
80101807:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
8010180b:	0f b7 50 f8          	movzwl -0x8(%eax),%edx
8010180f:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
80101813:	0f b7 50 fa          	movzwl -0x6(%eax),%edx
80101817:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
8010181b:	8b 50 fc             	mov    -0x4(%eax),%edx
8010181e:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101821:	6a 34                	push   $0x34
80101823:	50                   	push   %eax
80101824:	8d 43 5c             	lea    0x5c(%ebx),%eax
80101827:	50                   	push   %eax
80101828:	e8 a3 34 00 00       	call   80104cd0 <memmove>
    brelse(bp);
8010182d:	89 34 24             	mov    %esi,(%esp)
80101830:	e8 bb e9 ff ff       	call   801001f0 <brelse>
    if(ip->type == 0)
80101835:	83 c4 10             	add    $0x10,%esp
80101838:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
    ip->valid = 1;
8010183d:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101844:	0f 85 77 ff ff ff    	jne    801017c1 <ilock+0x31>
      panic("ilock: no type");
8010184a:	83 ec 0c             	sub    $0xc,%esp
8010184d:	68 d0 7c 10 80       	push   $0x80107cd0
80101852:	e8 29 eb ff ff       	call   80100380 <panic>
    panic("ilock");
80101857:	83 ec 0c             	sub    $0xc,%esp
8010185a:	68 ca 7c 10 80       	push   $0x80107cca
8010185f:	e8 1c eb ff ff       	call   80100380 <panic>
80101864:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010186b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010186f:	90                   	nop

80101870 <iunlock>:
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	56                   	push   %esi
80101874:	53                   	push   %ebx
80101875:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101878:	85 db                	test   %ebx,%ebx
8010187a:	74 28                	je     801018a4 <iunlock+0x34>
8010187c:	83 ec 0c             	sub    $0xc,%esp
8010187f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101882:	56                   	push   %esi
80101883:	e8 c8 30 00 00       	call   80104950 <holdingsleep>
80101888:	83 c4 10             	add    $0x10,%esp
8010188b:	85 c0                	test   %eax,%eax
8010188d:	74 15                	je     801018a4 <iunlock+0x34>
8010188f:	8b 43 08             	mov    0x8(%ebx),%eax
80101892:	85 c0                	test   %eax,%eax
80101894:	7e 0e                	jle    801018a4 <iunlock+0x34>
  releasesleep(&ip->lock);
80101896:	89 75 08             	mov    %esi,0x8(%ebp)
}
80101899:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010189c:	5b                   	pop    %ebx
8010189d:	5e                   	pop    %esi
8010189e:	5d                   	pop    %ebp
  releasesleep(&ip->lock);
8010189f:	e9 6c 30 00 00       	jmp    80104910 <releasesleep>
    panic("iunlock");
801018a4:	83 ec 0c             	sub    $0xc,%esp
801018a7:	68 df 7c 10 80       	push   $0x80107cdf
801018ac:	e8 cf ea ff ff       	call   80100380 <panic>
801018b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801018bf:	90                   	nop

801018c0 <iput>:
{
801018c0:	55                   	push   %ebp
801018c1:	89 e5                	mov    %esp,%ebp
801018c3:	57                   	push   %edi
801018c4:	56                   	push   %esi
801018c5:	53                   	push   %ebx
801018c6:	83 ec 28             	sub    $0x28,%esp
801018c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
801018cc:	8d 7b 0c             	lea    0xc(%ebx),%edi
801018cf:	57                   	push   %edi
801018d0:	e8 db 2f 00 00       	call   801048b0 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
801018d5:	8b 53 4c             	mov    0x4c(%ebx),%edx
801018d8:	83 c4 10             	add    $0x10,%esp
801018db:	85 d2                	test   %edx,%edx
801018dd:	74 07                	je     801018e6 <iput+0x26>
801018df:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801018e4:	74 32                	je     80101918 <iput+0x58>
  releasesleep(&ip->lock);
801018e6:	83 ec 0c             	sub    $0xc,%esp
801018e9:	57                   	push   %edi
801018ea:	e8 21 30 00 00       	call   80104910 <releasesleep>
  acquire(&icache.lock);
801018ef:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
801018f6:	e8 75 32 00 00       	call   80104b70 <acquire>
  ip->ref--;
801018fb:	83 6b 08 01          	subl   $0x1,0x8(%ebx)
  release(&icache.lock);
801018ff:	83 c4 10             	add    $0x10,%esp
80101902:	c7 45 08 60 09 11 80 	movl   $0x80110960,0x8(%ebp)
}
80101909:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010190c:	5b                   	pop    %ebx
8010190d:	5e                   	pop    %esi
8010190e:	5f                   	pop    %edi
8010190f:	5d                   	pop    %ebp
  release(&icache.lock);
80101910:	e9 fb 31 00 00       	jmp    80104b10 <release>
80101915:	8d 76 00             	lea    0x0(%esi),%esi
    acquire(&icache.lock);
80101918:	83 ec 0c             	sub    $0xc,%esp
8010191b:	68 60 09 11 80       	push   $0x80110960
80101920:	e8 4b 32 00 00       	call   80104b70 <acquire>
    int r = ip->ref;
80101925:	8b 73 08             	mov    0x8(%ebx),%esi
    release(&icache.lock);
80101928:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
8010192f:	e8 dc 31 00 00       	call   80104b10 <release>
    if(r == 1){
80101934:	83 c4 10             	add    $0x10,%esp
80101937:	83 fe 01             	cmp    $0x1,%esi
8010193a:	75 aa                	jne    801018e6 <iput+0x26>
8010193c:	8d 8b 8c 00 00 00    	lea    0x8c(%ebx),%ecx
80101942:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80101945:	8d 73 5c             	lea    0x5c(%ebx),%esi
80101948:	89 cf                	mov    %ecx,%edi
8010194a:	eb 0b                	jmp    80101957 <iput+0x97>
8010194c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101950:	83 c6 04             	add    $0x4,%esi
80101953:	39 fe                	cmp    %edi,%esi
80101955:	74 19                	je     80101970 <iput+0xb0>
    if(ip->addrs[i]){
80101957:	8b 16                	mov    (%esi),%edx
80101959:	85 d2                	test   %edx,%edx
8010195b:	74 f3                	je     80101950 <iput+0x90>
      bfree(ip->dev, ip->addrs[i]);
8010195d:	8b 03                	mov    (%ebx),%eax
8010195f:	e8 6c f8 ff ff       	call   801011d0 <bfree>
      ip->addrs[i] = 0;
80101964:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010196a:	eb e4                	jmp    80101950 <iput+0x90>
8010196c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    }
  }

  if(ip->addrs[NDIRECT]){
80101970:	8b 83 8c 00 00 00    	mov    0x8c(%ebx),%eax
80101976:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80101979:	85 c0                	test   %eax,%eax
8010197b:	75 2d                	jne    801019aa <iput+0xea>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
  iupdate(ip);
8010197d:	83 ec 0c             	sub    $0xc,%esp
  ip->size = 0;
80101980:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  iupdate(ip);
80101987:	53                   	push   %ebx
80101988:	e8 53 fd ff ff       	call   801016e0 <iupdate>
      ip->type = 0;
8010198d:	31 c0                	xor    %eax,%eax
8010198f:	66 89 43 50          	mov    %ax,0x50(%ebx)
      iupdate(ip);
80101993:	89 1c 24             	mov    %ebx,(%esp)
80101996:	e8 45 fd ff ff       	call   801016e0 <iupdate>
      ip->valid = 0;
8010199b:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
801019a2:	83 c4 10             	add    $0x10,%esp
801019a5:	e9 3c ff ff ff       	jmp    801018e6 <iput+0x26>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801019aa:	83 ec 08             	sub    $0x8,%esp
801019ad:	50                   	push   %eax
801019ae:	ff 33                	push   (%ebx)
801019b0:	e8 1b e7 ff ff       	call   801000d0 <bread>
801019b5:	89 7d e0             	mov    %edi,-0x20(%ebp)
801019b8:	83 c4 10             	add    $0x10,%esp
801019bb:	8d 88 5c 02 00 00    	lea    0x25c(%eax),%ecx
801019c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(j = 0; j < NINDIRECT; j++){
801019c4:	8d 70 5c             	lea    0x5c(%eax),%esi
801019c7:	89 cf                	mov    %ecx,%edi
801019c9:	eb 0c                	jmp    801019d7 <iput+0x117>
801019cb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801019cf:	90                   	nop
801019d0:	83 c6 04             	add    $0x4,%esi
801019d3:	39 f7                	cmp    %esi,%edi
801019d5:	74 0f                	je     801019e6 <iput+0x126>
      if(a[j])
801019d7:	8b 16                	mov    (%esi),%edx
801019d9:	85 d2                	test   %edx,%edx
801019db:	74 f3                	je     801019d0 <iput+0x110>
        bfree(ip->dev, a[j]);
801019dd:	8b 03                	mov    (%ebx),%eax
801019df:	e8 ec f7 ff ff       	call   801011d0 <bfree>
801019e4:	eb ea                	jmp    801019d0 <iput+0x110>
    brelse(bp);
801019e6:	83 ec 0c             	sub    $0xc,%esp
801019e9:	ff 75 e4             	push   -0x1c(%ebp)
801019ec:	8b 7d e0             	mov    -0x20(%ebp),%edi
801019ef:	e8 fc e7 ff ff       	call   801001f0 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
801019f4:	8b 93 8c 00 00 00    	mov    0x8c(%ebx),%edx
801019fa:	8b 03                	mov    (%ebx),%eax
801019fc:	e8 cf f7 ff ff       	call   801011d0 <bfree>
    ip->addrs[NDIRECT] = 0;
80101a01:	83 c4 10             	add    $0x10,%esp
80101a04:	c7 83 8c 00 00 00 00 	movl   $0x0,0x8c(%ebx)
80101a0b:	00 00 00 
80101a0e:	e9 6a ff ff ff       	jmp    8010197d <iput+0xbd>
80101a13:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101a1a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101a20 <iunlockput>:
{
80101a20:	55                   	push   %ebp
80101a21:	89 e5                	mov    %esp,%ebp
80101a23:	56                   	push   %esi
80101a24:	53                   	push   %ebx
80101a25:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101a28:	85 db                	test   %ebx,%ebx
80101a2a:	74 34                	je     80101a60 <iunlockput+0x40>
80101a2c:	83 ec 0c             	sub    $0xc,%esp
80101a2f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101a32:	56                   	push   %esi
80101a33:	e8 18 2f 00 00       	call   80104950 <holdingsleep>
80101a38:	83 c4 10             	add    $0x10,%esp
80101a3b:	85 c0                	test   %eax,%eax
80101a3d:	74 21                	je     80101a60 <iunlockput+0x40>
80101a3f:	8b 43 08             	mov    0x8(%ebx),%eax
80101a42:	85 c0                	test   %eax,%eax
80101a44:	7e 1a                	jle    80101a60 <iunlockput+0x40>
  releasesleep(&ip->lock);
80101a46:	83 ec 0c             	sub    $0xc,%esp
80101a49:	56                   	push   %esi
80101a4a:	e8 c1 2e 00 00       	call   80104910 <releasesleep>
  iput(ip);
80101a4f:	89 5d 08             	mov    %ebx,0x8(%ebp)
80101a52:	83 c4 10             	add    $0x10,%esp
}
80101a55:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101a58:	5b                   	pop    %ebx
80101a59:	5e                   	pop    %esi
80101a5a:	5d                   	pop    %ebp
  iput(ip);
80101a5b:	e9 60 fe ff ff       	jmp    801018c0 <iput>
    panic("iunlock");
80101a60:	83 ec 0c             	sub    $0xc,%esp
80101a63:	68 df 7c 10 80       	push   $0x80107cdf
80101a68:	e8 13 e9 ff ff       	call   80100380 <panic>
80101a6d:	8d 76 00             	lea    0x0(%esi),%esi

80101a70 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
80101a70:	55                   	push   %ebp
80101a71:	89 e5                	mov    %esp,%ebp
80101a73:	8b 55 08             	mov    0x8(%ebp),%edx
80101a76:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101a79:	8b 0a                	mov    (%edx),%ecx
80101a7b:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101a7e:	8b 4a 04             	mov    0x4(%edx),%ecx
80101a81:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
80101a84:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101a88:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101a8b:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101a8f:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
80101a93:	8b 52 58             	mov    0x58(%edx),%edx
80101a96:	89 50 10             	mov    %edx,0x10(%eax)
}
80101a99:	5d                   	pop    %ebp
80101a9a:	c3                   	ret    
80101a9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101a9f:	90                   	nop

80101aa0 <readi>:
//PAGEBREAK!
// Read data from inode.
// Caller must hold ip->lock.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101aa0:	55                   	push   %ebp
80101aa1:	89 e5                	mov    %esp,%ebp
80101aa3:	57                   	push   %edi
80101aa4:	56                   	push   %esi
80101aa5:	53                   	push   %ebx
80101aa6:	83 ec 1c             	sub    $0x1c,%esp
80101aa9:	8b 7d 0c             	mov    0xc(%ebp),%edi
80101aac:	8b 45 08             	mov    0x8(%ebp),%eax
80101aaf:	8b 75 10             	mov    0x10(%ebp),%esi
80101ab2:	89 7d e0             	mov    %edi,-0x20(%ebp)
80101ab5:	8b 7d 14             	mov    0x14(%ebp),%edi
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ab8:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101abd:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101ac0:	89 7d e4             	mov    %edi,-0x1c(%ebp)
  if(ip->type == T_DEV){
80101ac3:	0f 84 a7 00 00 00    	je     80101b70 <readi+0xd0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
      return -1;
    return devsw[ip->major].read(ip, dst, n);
  }

  if(off > ip->size || off + n < off)
80101ac9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101acc:	8b 40 58             	mov    0x58(%eax),%eax
80101acf:	39 c6                	cmp    %eax,%esi
80101ad1:	0f 87 ba 00 00 00    	ja     80101b91 <readi+0xf1>
80101ad7:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101ada:	31 c9                	xor    %ecx,%ecx
80101adc:	89 da                	mov    %ebx,%edx
80101ade:	01 f2                	add    %esi,%edx
80101ae0:	0f 92 c1             	setb   %cl
80101ae3:	89 cf                	mov    %ecx,%edi
80101ae5:	0f 82 a6 00 00 00    	jb     80101b91 <readi+0xf1>
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;
80101aeb:	89 c1                	mov    %eax,%ecx
80101aed:	29 f1                	sub    %esi,%ecx
80101aef:	39 d0                	cmp    %edx,%eax
80101af1:	0f 43 cb             	cmovae %ebx,%ecx
80101af4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101af7:	85 c9                	test   %ecx,%ecx
80101af9:	74 67                	je     80101b62 <readi+0xc2>
80101afb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101aff:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101b00:	8b 5d d8             	mov    -0x28(%ebp),%ebx
80101b03:	89 f2                	mov    %esi,%edx
80101b05:	c1 ea 09             	shr    $0x9,%edx
80101b08:	89 d8                	mov    %ebx,%eax
80101b0a:	e8 51 f9 ff ff       	call   80101460 <bmap>
80101b0f:	83 ec 08             	sub    $0x8,%esp
80101b12:	50                   	push   %eax
80101b13:	ff 33                	push   (%ebx)
80101b15:	e8 b6 e5 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101b1a:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80101b1d:	b9 00 02 00 00       	mov    $0x200,%ecx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101b22:	89 c2                	mov    %eax,%edx
    m = min(n - tot, BSIZE - off%BSIZE);
80101b24:	89 f0                	mov    %esi,%eax
80101b26:	25 ff 01 00 00       	and    $0x1ff,%eax
80101b2b:	29 fb                	sub    %edi,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101b2d:	89 55 dc             	mov    %edx,-0x24(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101b30:	29 c1                	sub    %eax,%ecx
    memmove(dst, bp->data + off%BSIZE, m);
80101b32:	8d 44 02 5c          	lea    0x5c(%edx,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101b36:	39 d9                	cmp    %ebx,%ecx
80101b38:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
80101b3b:	83 c4 0c             	add    $0xc,%esp
80101b3e:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101b3f:	01 df                	add    %ebx,%edi
80101b41:	01 de                	add    %ebx,%esi
    memmove(dst, bp->data + off%BSIZE, m);
80101b43:	50                   	push   %eax
80101b44:	ff 75 e0             	push   -0x20(%ebp)
80101b47:	e8 84 31 00 00       	call   80104cd0 <memmove>
    brelse(bp);
80101b4c:	8b 55 dc             	mov    -0x24(%ebp),%edx
80101b4f:	89 14 24             	mov    %edx,(%esp)
80101b52:	e8 99 e6 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101b57:	01 5d e0             	add    %ebx,-0x20(%ebp)
80101b5a:	83 c4 10             	add    $0x10,%esp
80101b5d:	39 7d e4             	cmp    %edi,-0x1c(%ebp)
80101b60:	77 9e                	ja     80101b00 <readi+0x60>
  }
  return n;
80101b62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
80101b65:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b68:	5b                   	pop    %ebx
80101b69:	5e                   	pop    %esi
80101b6a:	5f                   	pop    %edi
80101b6b:	5d                   	pop    %ebp
80101b6c:	c3                   	ret    
80101b6d:	8d 76 00             	lea    0x0(%esi),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101b70:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101b74:	66 83 f8 09          	cmp    $0x9,%ax
80101b78:	77 17                	ja     80101b91 <readi+0xf1>
80101b7a:	8b 04 c5 00 09 11 80 	mov    -0x7feef700(,%eax,8),%eax
80101b81:	85 c0                	test   %eax,%eax
80101b83:	74 0c                	je     80101b91 <readi+0xf1>
    return devsw[ip->major].read(ip, dst, n);
80101b85:	89 7d 10             	mov    %edi,0x10(%ebp)
}
80101b88:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101b8b:	5b                   	pop    %ebx
80101b8c:	5e                   	pop    %esi
80101b8d:	5f                   	pop    %edi
80101b8e:	5d                   	pop    %ebp
    return devsw[ip->major].read(ip, dst, n);
80101b8f:	ff e0                	jmp    *%eax
      return -1;
80101b91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b96:	eb cd                	jmp    80101b65 <readi+0xc5>
80101b98:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101b9f:	90                   	nop

80101ba0 <writei>:
// PAGEBREAK!
// Write data to inode.
// Caller must hold ip->lock.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80101ba0:	55                   	push   %ebp
80101ba1:	89 e5                	mov    %esp,%ebp
80101ba3:	57                   	push   %edi
80101ba4:	56                   	push   %esi
80101ba5:	53                   	push   %ebx
80101ba6:	83 ec 1c             	sub    $0x1c,%esp
80101ba9:	8b 45 08             	mov    0x8(%ebp),%eax
80101bac:	8b 75 0c             	mov    0xc(%ebp),%esi
80101baf:	8b 55 14             	mov    0x14(%ebp),%edx
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101bb2:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
{
80101bb7:	89 75 dc             	mov    %esi,-0x24(%ebp)
80101bba:	89 45 d8             	mov    %eax,-0x28(%ebp)
80101bbd:	8b 75 10             	mov    0x10(%ebp),%esi
80101bc0:	89 55 e0             	mov    %edx,-0x20(%ebp)
  if(ip->type == T_DEV){
80101bc3:	0f 84 b7 00 00 00    	je     80101c80 <writei+0xe0>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
      return -1;
    return devsw[ip->major].write(ip, src, n);
  }

  if(off > ip->size || off + n < off)
80101bc9:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101bcc:	3b 70 58             	cmp    0x58(%eax),%esi
80101bcf:	0f 87 e7 00 00 00    	ja     80101cbc <writei+0x11c>
80101bd5:	8b 7d e0             	mov    -0x20(%ebp),%edi
80101bd8:	31 d2                	xor    %edx,%edx
80101bda:	89 f8                	mov    %edi,%eax
80101bdc:	01 f0                	add    %esi,%eax
80101bde:	0f 92 c2             	setb   %dl
    return -1;
  if(off + n > MAXFILE*BSIZE)
80101be1:	3d 00 18 01 00       	cmp    $0x11800,%eax
80101be6:	0f 87 d0 00 00 00    	ja     80101cbc <writei+0x11c>
80101bec:	85 d2                	test   %edx,%edx
80101bee:	0f 85 c8 00 00 00    	jne    80101cbc <writei+0x11c>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101bf4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80101bfb:	85 ff                	test   %edi,%edi
80101bfd:	74 72                	je     80101c71 <writei+0xd1>
80101bff:	90                   	nop
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c00:	8b 7d d8             	mov    -0x28(%ebp),%edi
80101c03:	89 f2                	mov    %esi,%edx
80101c05:	c1 ea 09             	shr    $0x9,%edx
80101c08:	89 f8                	mov    %edi,%eax
80101c0a:	e8 51 f8 ff ff       	call   80101460 <bmap>
80101c0f:	83 ec 08             	sub    $0x8,%esp
80101c12:	50                   	push   %eax
80101c13:	ff 37                	push   (%edi)
80101c15:	e8 b6 e4 ff ff       	call   801000d0 <bread>
    m = min(n - tot, BSIZE - off%BSIZE);
80101c1a:	b9 00 02 00 00       	mov    $0x200,%ecx
80101c1f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
80101c22:	2b 5d e4             	sub    -0x1c(%ebp),%ebx
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101c25:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101c27:	89 f0                	mov    %esi,%eax
80101c29:	25 ff 01 00 00       	and    $0x1ff,%eax
80101c2e:	29 c1                	sub    %eax,%ecx
    memmove(bp->data + off%BSIZE, src, m);
80101c30:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
    m = min(n - tot, BSIZE - off%BSIZE);
80101c34:	39 d9                	cmp    %ebx,%ecx
80101c36:	0f 46 d9             	cmovbe %ecx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
80101c39:	83 c4 0c             	add    $0xc,%esp
80101c3c:	53                   	push   %ebx
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101c3d:	01 de                	add    %ebx,%esi
    memmove(bp->data + off%BSIZE, src, m);
80101c3f:	ff 75 dc             	push   -0x24(%ebp)
80101c42:	50                   	push   %eax
80101c43:	e8 88 30 00 00       	call   80104cd0 <memmove>
    log_write(bp);
80101c48:	89 3c 24             	mov    %edi,(%esp)
80101c4b:	e8 00 13 00 00       	call   80102f50 <log_write>
    brelse(bp);
80101c50:	89 3c 24             	mov    %edi,(%esp)
80101c53:	e8 98 e5 ff ff       	call   801001f0 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80101c58:	01 5d e4             	add    %ebx,-0x1c(%ebp)
80101c5b:	83 c4 10             	add    $0x10,%esp
80101c5e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80101c61:	01 5d dc             	add    %ebx,-0x24(%ebp)
80101c64:	39 45 e0             	cmp    %eax,-0x20(%ebp)
80101c67:	77 97                	ja     80101c00 <writei+0x60>
  }

  if(n > 0 && off > ip->size){
80101c69:	8b 45 d8             	mov    -0x28(%ebp),%eax
80101c6c:	3b 70 58             	cmp    0x58(%eax),%esi
80101c6f:	77 37                	ja     80101ca8 <writei+0x108>
    ip->size = off;
    iupdate(ip);
  }
  return n;
80101c71:	8b 45 e0             	mov    -0x20(%ebp),%eax
}
80101c74:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c77:	5b                   	pop    %ebx
80101c78:	5e                   	pop    %esi
80101c79:	5f                   	pop    %edi
80101c7a:	5d                   	pop    %ebp
80101c7b:	c3                   	ret    
80101c7c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80101c80:	0f bf 40 52          	movswl 0x52(%eax),%eax
80101c84:	66 83 f8 09          	cmp    $0x9,%ax
80101c88:	77 32                	ja     80101cbc <writei+0x11c>
80101c8a:	8b 04 c5 04 09 11 80 	mov    -0x7feef6fc(,%eax,8),%eax
80101c91:	85 c0                	test   %eax,%eax
80101c93:	74 27                	je     80101cbc <writei+0x11c>
    return devsw[ip->major].write(ip, src, n);
80101c95:	89 55 10             	mov    %edx,0x10(%ebp)
}
80101c98:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101c9b:	5b                   	pop    %ebx
80101c9c:	5e                   	pop    %esi
80101c9d:	5f                   	pop    %edi
80101c9e:	5d                   	pop    %ebp
    return devsw[ip->major].write(ip, src, n);
80101c9f:	ff e0                	jmp    *%eax
80101ca1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    ip->size = off;
80101ca8:	8b 45 d8             	mov    -0x28(%ebp),%eax
    iupdate(ip);
80101cab:	83 ec 0c             	sub    $0xc,%esp
    ip->size = off;
80101cae:	89 70 58             	mov    %esi,0x58(%eax)
    iupdate(ip);
80101cb1:	50                   	push   %eax
80101cb2:	e8 29 fa ff ff       	call   801016e0 <iupdate>
80101cb7:	83 c4 10             	add    $0x10,%esp
80101cba:	eb b5                	jmp    80101c71 <writei+0xd1>
      return -1;
80101cbc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101cc1:	eb b1                	jmp    80101c74 <writei+0xd4>
80101cc3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80101cd0 <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
80101cd0:	55                   	push   %ebp
80101cd1:	89 e5                	mov    %esp,%ebp
80101cd3:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
80101cd6:	6a 0e                	push   $0xe
80101cd8:	ff 75 0c             	push   0xc(%ebp)
80101cdb:	ff 75 08             	push   0x8(%ebp)
80101cde:	e8 5d 30 00 00       	call   80104d40 <strncmp>
}
80101ce3:	c9                   	leave  
80101ce4:	c3                   	ret    
80101ce5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80101cec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80101cf0 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
80101cf0:	55                   	push   %ebp
80101cf1:	89 e5                	mov    %esp,%ebp
80101cf3:	57                   	push   %edi
80101cf4:	56                   	push   %esi
80101cf5:	53                   	push   %ebx
80101cf6:	83 ec 1c             	sub    $0x1c,%esp
80101cf9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
80101cfc:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101d01:	0f 85 85 00 00 00    	jne    80101d8c <dirlookup+0x9c>
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80101d07:	8b 53 58             	mov    0x58(%ebx),%edx
80101d0a:	31 ff                	xor    %edi,%edi
80101d0c:	8d 75 d8             	lea    -0x28(%ebp),%esi
80101d0f:	85 d2                	test   %edx,%edx
80101d11:	74 3e                	je     80101d51 <dirlookup+0x61>
80101d13:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101d17:	90                   	nop
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101d18:	6a 10                	push   $0x10
80101d1a:	57                   	push   %edi
80101d1b:	56                   	push   %esi
80101d1c:	53                   	push   %ebx
80101d1d:	e8 7e fd ff ff       	call   80101aa0 <readi>
80101d22:	83 c4 10             	add    $0x10,%esp
80101d25:	83 f8 10             	cmp    $0x10,%eax
80101d28:	75 55                	jne    80101d7f <dirlookup+0x8f>
      panic("dirlookup read");
    if(de.inum == 0)
80101d2a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101d2f:	74 18                	je     80101d49 <dirlookup+0x59>
  return strncmp(s, t, DIRSIZ);
80101d31:	83 ec 04             	sub    $0x4,%esp
80101d34:	8d 45 da             	lea    -0x26(%ebp),%eax
80101d37:	6a 0e                	push   $0xe
80101d39:	50                   	push   %eax
80101d3a:	ff 75 0c             	push   0xc(%ebp)
80101d3d:	e8 fe 2f 00 00       	call   80104d40 <strncmp>
      continue;
    if(namecmp(name, de.name) == 0){
80101d42:	83 c4 10             	add    $0x10,%esp
80101d45:	85 c0                	test   %eax,%eax
80101d47:	74 17                	je     80101d60 <dirlookup+0x70>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101d49:	83 c7 10             	add    $0x10,%edi
80101d4c:	3b 7b 58             	cmp    0x58(%ebx),%edi
80101d4f:	72 c7                	jb     80101d18 <dirlookup+0x28>
      return iget(dp->dev, inum);
    }
  }

  return 0;
}
80101d51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80101d54:	31 c0                	xor    %eax,%eax
}
80101d56:	5b                   	pop    %ebx
80101d57:	5e                   	pop    %esi
80101d58:	5f                   	pop    %edi
80101d59:	5d                   	pop    %ebp
80101d5a:	c3                   	ret    
80101d5b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80101d5f:	90                   	nop
      if(poff)
80101d60:	8b 45 10             	mov    0x10(%ebp),%eax
80101d63:	85 c0                	test   %eax,%eax
80101d65:	74 05                	je     80101d6c <dirlookup+0x7c>
        *poff = off;
80101d67:	8b 45 10             	mov    0x10(%ebp),%eax
80101d6a:	89 38                	mov    %edi,(%eax)
      inum = de.inum;
80101d6c:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101d70:	8b 03                	mov    (%ebx),%eax
80101d72:	e8 e9 f5 ff ff       	call   80101360 <iget>
}
80101d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101d7a:	5b                   	pop    %ebx
80101d7b:	5e                   	pop    %esi
80101d7c:	5f                   	pop    %edi
80101d7d:	5d                   	pop    %ebp
80101d7e:	c3                   	ret    
      panic("dirlookup read");
80101d7f:	83 ec 0c             	sub    $0xc,%esp
80101d82:	68 f9 7c 10 80       	push   $0x80107cf9
80101d87:	e8 f4 e5 ff ff       	call   80100380 <panic>
    panic("dirlookup not DIR");
80101d8c:	83 ec 0c             	sub    $0xc,%esp
80101d8f:	68 e7 7c 10 80       	push   $0x80107ce7
80101d94:	e8 e7 e5 ff ff       	call   80100380 <panic>
80101d99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101da0 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101da0:	55                   	push   %ebp
80101da1:	89 e5                	mov    %esp,%ebp
80101da3:	57                   	push   %edi
80101da4:	56                   	push   %esi
80101da5:	53                   	push   %ebx
80101da6:	89 c3                	mov    %eax,%ebx
80101da8:	83 ec 1c             	sub    $0x1c,%esp
  struct inode *ip, *next;

  if(*path == '/')
80101dab:	80 38 2f             	cmpb   $0x2f,(%eax)
{
80101dae:	89 55 dc             	mov    %edx,-0x24(%ebp)
80101db1:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  if(*path == '/')
80101db4:	0f 84 64 01 00 00    	je     80101f1e <namex+0x17e>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101dba:	e8 f1 1b 00 00       	call   801039b0 <myproc>
  acquire(&icache.lock);
80101dbf:	83 ec 0c             	sub    $0xc,%esp
    ip = idup(myproc()->cwd);
80101dc2:	8b 70 68             	mov    0x68(%eax),%esi
  acquire(&icache.lock);
80101dc5:	68 60 09 11 80       	push   $0x80110960
80101dca:	e8 a1 2d 00 00       	call   80104b70 <acquire>
  ip->ref++;
80101dcf:	83 46 08 01          	addl   $0x1,0x8(%esi)
  release(&icache.lock);
80101dd3:	c7 04 24 60 09 11 80 	movl   $0x80110960,(%esp)
80101dda:	e8 31 2d 00 00       	call   80104b10 <release>
80101ddf:	83 c4 10             	add    $0x10,%esp
80101de2:	eb 07                	jmp    80101deb <namex+0x4b>
80101de4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101de8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101deb:	0f b6 03             	movzbl (%ebx),%eax
80101dee:	3c 2f                	cmp    $0x2f,%al
80101df0:	74 f6                	je     80101de8 <namex+0x48>
  if(*path == 0)
80101df2:	84 c0                	test   %al,%al
80101df4:	0f 84 06 01 00 00    	je     80101f00 <namex+0x160>
  while(*path != '/' && *path != 0)
80101dfa:	0f b6 03             	movzbl (%ebx),%eax
80101dfd:	84 c0                	test   %al,%al
80101dff:	0f 84 10 01 00 00    	je     80101f15 <namex+0x175>
80101e05:	89 df                	mov    %ebx,%edi
80101e07:	3c 2f                	cmp    $0x2f,%al
80101e09:	0f 84 06 01 00 00    	je     80101f15 <namex+0x175>
80101e0f:	90                   	nop
80101e10:	0f b6 47 01          	movzbl 0x1(%edi),%eax
    path++;
80101e14:	83 c7 01             	add    $0x1,%edi
  while(*path != '/' && *path != 0)
80101e17:	3c 2f                	cmp    $0x2f,%al
80101e19:	74 04                	je     80101e1f <namex+0x7f>
80101e1b:	84 c0                	test   %al,%al
80101e1d:	75 f1                	jne    80101e10 <namex+0x70>
  len = path - s;
80101e1f:	89 f8                	mov    %edi,%eax
80101e21:	29 d8                	sub    %ebx,%eax
  if(len >= DIRSIZ)
80101e23:	83 f8 0d             	cmp    $0xd,%eax
80101e26:	0f 8e ac 00 00 00    	jle    80101ed8 <namex+0x138>
    memmove(name, s, DIRSIZ);
80101e2c:	83 ec 04             	sub    $0x4,%esp
80101e2f:	6a 0e                	push   $0xe
80101e31:	53                   	push   %ebx
    path++;
80101e32:	89 fb                	mov    %edi,%ebx
    memmove(name, s, DIRSIZ);
80101e34:	ff 75 e4             	push   -0x1c(%ebp)
80101e37:	e8 94 2e 00 00       	call   80104cd0 <memmove>
80101e3c:	83 c4 10             	add    $0x10,%esp
  while(*path == '/')
80101e3f:	80 3f 2f             	cmpb   $0x2f,(%edi)
80101e42:	75 0c                	jne    80101e50 <namex+0xb0>
80101e44:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    path++;
80101e48:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80101e4b:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80101e4e:	74 f8                	je     80101e48 <namex+0xa8>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
80101e50:	83 ec 0c             	sub    $0xc,%esp
80101e53:	56                   	push   %esi
80101e54:	e8 37 f9 ff ff       	call   80101790 <ilock>
    if(ip->type != T_DIR){
80101e59:	83 c4 10             	add    $0x10,%esp
80101e5c:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80101e61:	0f 85 cd 00 00 00    	jne    80101f34 <namex+0x194>
      iunlockput(ip);
      return 0;
    }
    if(nameiparent && *path == '\0'){
80101e67:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101e6a:	85 c0                	test   %eax,%eax
80101e6c:	74 09                	je     80101e77 <namex+0xd7>
80101e6e:	80 3b 00             	cmpb   $0x0,(%ebx)
80101e71:	0f 84 22 01 00 00    	je     80101f99 <namex+0x1f9>
      // Stop one level early.
      iunlock(ip);
      return ip;
    }
    if((next = dirlookup(ip, name, 0)) == 0){
80101e77:	83 ec 04             	sub    $0x4,%esp
80101e7a:	6a 00                	push   $0x0
80101e7c:	ff 75 e4             	push   -0x1c(%ebp)
80101e7f:	56                   	push   %esi
80101e80:	e8 6b fe ff ff       	call   80101cf0 <dirlookup>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101e85:	8d 56 0c             	lea    0xc(%esi),%edx
    if((next = dirlookup(ip, name, 0)) == 0){
80101e88:	83 c4 10             	add    $0x10,%esp
80101e8b:	89 c7                	mov    %eax,%edi
80101e8d:	85 c0                	test   %eax,%eax
80101e8f:	0f 84 e1 00 00 00    	je     80101f76 <namex+0x1d6>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101e95:	83 ec 0c             	sub    $0xc,%esp
80101e98:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101e9b:	52                   	push   %edx
80101e9c:	e8 af 2a 00 00       	call   80104950 <holdingsleep>
80101ea1:	83 c4 10             	add    $0x10,%esp
80101ea4:	85 c0                	test   %eax,%eax
80101ea6:	0f 84 30 01 00 00    	je     80101fdc <namex+0x23c>
80101eac:	8b 56 08             	mov    0x8(%esi),%edx
80101eaf:	85 d2                	test   %edx,%edx
80101eb1:	0f 8e 25 01 00 00    	jle    80101fdc <namex+0x23c>
  releasesleep(&ip->lock);
80101eb7:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101eba:	83 ec 0c             	sub    $0xc,%esp
80101ebd:	52                   	push   %edx
80101ebe:	e8 4d 2a 00 00       	call   80104910 <releasesleep>
  iput(ip);
80101ec3:	89 34 24             	mov    %esi,(%esp)
80101ec6:	89 fe                	mov    %edi,%esi
80101ec8:	e8 f3 f9 ff ff       	call   801018c0 <iput>
80101ecd:	83 c4 10             	add    $0x10,%esp
80101ed0:	e9 16 ff ff ff       	jmp    80101deb <namex+0x4b>
80101ed5:	8d 76 00             	lea    0x0(%esi),%esi
    name[len] = 0;
80101ed8:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80101edb:	8d 14 01             	lea    (%ecx,%eax,1),%edx
    memmove(name, s, len);
80101ede:	83 ec 04             	sub    $0x4,%esp
80101ee1:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101ee4:	50                   	push   %eax
80101ee5:	53                   	push   %ebx
    name[len] = 0;
80101ee6:	89 fb                	mov    %edi,%ebx
    memmove(name, s, len);
80101ee8:	ff 75 e4             	push   -0x1c(%ebp)
80101eeb:	e8 e0 2d 00 00       	call   80104cd0 <memmove>
    name[len] = 0;
80101ef0:	8b 55 e0             	mov    -0x20(%ebp),%edx
80101ef3:	83 c4 10             	add    $0x10,%esp
80101ef6:	c6 02 00             	movb   $0x0,(%edx)
80101ef9:	e9 41 ff ff ff       	jmp    80101e3f <namex+0x9f>
80101efe:	66 90                	xchg   %ax,%ax
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
80101f00:	8b 45 dc             	mov    -0x24(%ebp),%eax
80101f03:	85 c0                	test   %eax,%eax
80101f05:	0f 85 be 00 00 00    	jne    80101fc9 <namex+0x229>
    iput(ip);
    return 0;
  }
  return ip;
}
80101f0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f0e:	89 f0                	mov    %esi,%eax
80101f10:	5b                   	pop    %ebx
80101f11:	5e                   	pop    %esi
80101f12:	5f                   	pop    %edi
80101f13:	5d                   	pop    %ebp
80101f14:	c3                   	ret    
  while(*path != '/' && *path != 0)
80101f15:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101f18:	89 df                	mov    %ebx,%edi
80101f1a:	31 c0                	xor    %eax,%eax
80101f1c:	eb c0                	jmp    80101ede <namex+0x13e>
    ip = iget(ROOTDEV, ROOTINO);
80101f1e:	ba 01 00 00 00       	mov    $0x1,%edx
80101f23:	b8 01 00 00 00       	mov    $0x1,%eax
80101f28:	e8 33 f4 ff ff       	call   80101360 <iget>
80101f2d:	89 c6                	mov    %eax,%esi
80101f2f:	e9 b7 fe ff ff       	jmp    80101deb <namex+0x4b>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f34:	83 ec 0c             	sub    $0xc,%esp
80101f37:	8d 5e 0c             	lea    0xc(%esi),%ebx
80101f3a:	53                   	push   %ebx
80101f3b:	e8 10 2a 00 00       	call   80104950 <holdingsleep>
80101f40:	83 c4 10             	add    $0x10,%esp
80101f43:	85 c0                	test   %eax,%eax
80101f45:	0f 84 91 00 00 00    	je     80101fdc <namex+0x23c>
80101f4b:	8b 46 08             	mov    0x8(%esi),%eax
80101f4e:	85 c0                	test   %eax,%eax
80101f50:	0f 8e 86 00 00 00    	jle    80101fdc <namex+0x23c>
  releasesleep(&ip->lock);
80101f56:	83 ec 0c             	sub    $0xc,%esp
80101f59:	53                   	push   %ebx
80101f5a:	e8 b1 29 00 00       	call   80104910 <releasesleep>
  iput(ip);
80101f5f:	89 34 24             	mov    %esi,(%esp)
      return 0;
80101f62:	31 f6                	xor    %esi,%esi
  iput(ip);
80101f64:	e8 57 f9 ff ff       	call   801018c0 <iput>
      return 0;
80101f69:	83 c4 10             	add    $0x10,%esp
}
80101f6c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f6f:	89 f0                	mov    %esi,%eax
80101f71:	5b                   	pop    %ebx
80101f72:	5e                   	pop    %esi
80101f73:	5f                   	pop    %edi
80101f74:	5d                   	pop    %ebp
80101f75:	c3                   	ret    
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f76:	83 ec 0c             	sub    $0xc,%esp
80101f79:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80101f7c:	52                   	push   %edx
80101f7d:	e8 ce 29 00 00       	call   80104950 <holdingsleep>
80101f82:	83 c4 10             	add    $0x10,%esp
80101f85:	85 c0                	test   %eax,%eax
80101f87:	74 53                	je     80101fdc <namex+0x23c>
80101f89:	8b 4e 08             	mov    0x8(%esi),%ecx
80101f8c:	85 c9                	test   %ecx,%ecx
80101f8e:	7e 4c                	jle    80101fdc <namex+0x23c>
  releasesleep(&ip->lock);
80101f90:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101f93:	83 ec 0c             	sub    $0xc,%esp
80101f96:	52                   	push   %edx
80101f97:	eb c1                	jmp    80101f5a <namex+0x1ba>
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
80101f99:	83 ec 0c             	sub    $0xc,%esp
80101f9c:	8d 5e 0c             	lea    0xc(%esi),%ebx
80101f9f:	53                   	push   %ebx
80101fa0:	e8 ab 29 00 00       	call   80104950 <holdingsleep>
80101fa5:	83 c4 10             	add    $0x10,%esp
80101fa8:	85 c0                	test   %eax,%eax
80101faa:	74 30                	je     80101fdc <namex+0x23c>
80101fac:	8b 7e 08             	mov    0x8(%esi),%edi
80101faf:	85 ff                	test   %edi,%edi
80101fb1:	7e 29                	jle    80101fdc <namex+0x23c>
  releasesleep(&ip->lock);
80101fb3:	83 ec 0c             	sub    $0xc,%esp
80101fb6:	53                   	push   %ebx
80101fb7:	e8 54 29 00 00       	call   80104910 <releasesleep>
}
80101fbc:	83 c4 10             	add    $0x10,%esp
}
80101fbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101fc2:	89 f0                	mov    %esi,%eax
80101fc4:	5b                   	pop    %ebx
80101fc5:	5e                   	pop    %esi
80101fc6:	5f                   	pop    %edi
80101fc7:	5d                   	pop    %ebp
80101fc8:	c3                   	ret    
    iput(ip);
80101fc9:	83 ec 0c             	sub    $0xc,%esp
80101fcc:	56                   	push   %esi
    return 0;
80101fcd:	31 f6                	xor    %esi,%esi
    iput(ip);
80101fcf:	e8 ec f8 ff ff       	call   801018c0 <iput>
    return 0;
80101fd4:	83 c4 10             	add    $0x10,%esp
80101fd7:	e9 2f ff ff ff       	jmp    80101f0b <namex+0x16b>
    panic("iunlock");
80101fdc:	83 ec 0c             	sub    $0xc,%esp
80101fdf:	68 df 7c 10 80       	push   $0x80107cdf
80101fe4:	e8 97 e3 ff ff       	call   80100380 <panic>
80101fe9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80101ff0 <dirlink>:
{
80101ff0:	55                   	push   %ebp
80101ff1:	89 e5                	mov    %esp,%ebp
80101ff3:	57                   	push   %edi
80101ff4:	56                   	push   %esi
80101ff5:	53                   	push   %ebx
80101ff6:	83 ec 20             	sub    $0x20,%esp
80101ff9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if((ip = dirlookup(dp, name, 0)) != 0){
80101ffc:	6a 00                	push   $0x0
80101ffe:	ff 75 0c             	push   0xc(%ebp)
80102001:	53                   	push   %ebx
80102002:	e8 e9 fc ff ff       	call   80101cf0 <dirlookup>
80102007:	83 c4 10             	add    $0x10,%esp
8010200a:	85 c0                	test   %eax,%eax
8010200c:	75 67                	jne    80102075 <dirlink+0x85>
  for(off = 0; off < dp->size; off += sizeof(de)){
8010200e:	8b 7b 58             	mov    0x58(%ebx),%edi
80102011:	8d 75 d8             	lea    -0x28(%ebp),%esi
80102014:	85 ff                	test   %edi,%edi
80102016:	74 29                	je     80102041 <dirlink+0x51>
80102018:	31 ff                	xor    %edi,%edi
8010201a:	8d 75 d8             	lea    -0x28(%ebp),%esi
8010201d:	eb 09                	jmp    80102028 <dirlink+0x38>
8010201f:	90                   	nop
80102020:	83 c7 10             	add    $0x10,%edi
80102023:	3b 7b 58             	cmp    0x58(%ebx),%edi
80102026:	73 19                	jae    80102041 <dirlink+0x51>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102028:	6a 10                	push   $0x10
8010202a:	57                   	push   %edi
8010202b:	56                   	push   %esi
8010202c:	53                   	push   %ebx
8010202d:	e8 6e fa ff ff       	call   80101aa0 <readi>
80102032:	83 c4 10             	add    $0x10,%esp
80102035:	83 f8 10             	cmp    $0x10,%eax
80102038:	75 4e                	jne    80102088 <dirlink+0x98>
    if(de.inum == 0)
8010203a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010203f:	75 df                	jne    80102020 <dirlink+0x30>
  strncpy(de.name, name, DIRSIZ);
80102041:	83 ec 04             	sub    $0x4,%esp
80102044:	8d 45 da             	lea    -0x26(%ebp),%eax
80102047:	6a 0e                	push   $0xe
80102049:	ff 75 0c             	push   0xc(%ebp)
8010204c:	50                   	push   %eax
8010204d:	e8 3e 2d 00 00       	call   80104d90 <strncpy>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102052:	6a 10                	push   $0x10
  de.inum = inum;
80102054:	8b 45 10             	mov    0x10(%ebp),%eax
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80102057:	57                   	push   %edi
80102058:	56                   	push   %esi
80102059:	53                   	push   %ebx
  de.inum = inum;
8010205a:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010205e:	e8 3d fb ff ff       	call   80101ba0 <writei>
80102063:	83 c4 20             	add    $0x20,%esp
80102066:	83 f8 10             	cmp    $0x10,%eax
80102069:	75 2a                	jne    80102095 <dirlink+0xa5>
  return 0;
8010206b:	31 c0                	xor    %eax,%eax
}
8010206d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102070:	5b                   	pop    %ebx
80102071:	5e                   	pop    %esi
80102072:	5f                   	pop    %edi
80102073:	5d                   	pop    %ebp
80102074:	c3                   	ret    
    iput(ip);
80102075:	83 ec 0c             	sub    $0xc,%esp
80102078:	50                   	push   %eax
80102079:	e8 42 f8 ff ff       	call   801018c0 <iput>
    return -1;
8010207e:	83 c4 10             	add    $0x10,%esp
80102081:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102086:	eb e5                	jmp    8010206d <dirlink+0x7d>
      panic("dirlink read");
80102088:	83 ec 0c             	sub    $0xc,%esp
8010208b:	68 08 7d 10 80       	push   $0x80107d08
80102090:	e8 eb e2 ff ff       	call   80100380 <panic>
    panic("dirlink");
80102095:	83 ec 0c             	sub    $0xc,%esp
80102098:	68 ee 82 10 80       	push   $0x801082ee
8010209d:	e8 de e2 ff ff       	call   80100380 <panic>
801020a2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801020a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801020b0 <namei>:

struct inode*
namei(char *path)
{
801020b0:	55                   	push   %ebp
  char name[DIRSIZ];
  return namex(path, 0, name);
801020b1:	31 d2                	xor    %edx,%edx
{
801020b3:	89 e5                	mov    %esp,%ebp
801020b5:	83 ec 18             	sub    $0x18,%esp
  return namex(path, 0, name);
801020b8:	8b 45 08             	mov    0x8(%ebp),%eax
801020bb:	8d 4d ea             	lea    -0x16(%ebp),%ecx
801020be:	e8 dd fc ff ff       	call   80101da0 <namex>
}
801020c3:	c9                   	leave  
801020c4:	c3                   	ret    
801020c5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801020cc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801020d0 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
801020d0:	55                   	push   %ebp
  return namex(path, 1, name);
801020d1:	ba 01 00 00 00       	mov    $0x1,%edx
{
801020d6:	89 e5                	mov    %esp,%ebp
  return namex(path, 1, name);
801020d8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801020db:	8b 45 08             	mov    0x8(%ebp),%eax
}
801020de:	5d                   	pop    %ebp
  return namex(path, 1, name);
801020df:	e9 bc fc ff ff       	jmp    80101da0 <namex>
801020e4:	66 90                	xchg   %ax,%ax
801020e6:	66 90                	xchg   %ax,%ax
801020e8:	66 90                	xchg   %ax,%ax
801020ea:	66 90                	xchg   %ax,%ax
801020ec:	66 90                	xchg   %ax,%ax
801020ee:	66 90                	xchg   %ax,%ax

801020f0 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801020f0:	55                   	push   %ebp
801020f1:	89 e5                	mov    %esp,%ebp
801020f3:	57                   	push   %edi
801020f4:	56                   	push   %esi
801020f5:	53                   	push   %ebx
801020f6:	83 ec 0c             	sub    $0xc,%esp
  if(b == 0)
801020f9:	85 c0                	test   %eax,%eax
801020fb:	0f 84 b4 00 00 00    	je     801021b5 <idestart+0xc5>
    panic("idestart");
  if(b->blockno >= FSSIZE)
80102101:	8b 70 08             	mov    0x8(%eax),%esi
80102104:	89 c3                	mov    %eax,%ebx
80102106:	81 fe e7 03 00 00    	cmp    $0x3e7,%esi
8010210c:	0f 87 96 00 00 00    	ja     801021a8 <idestart+0xb8>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102112:	b9 f7 01 00 00       	mov    $0x1f7,%ecx
80102117:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010211e:	66 90                	xchg   %ax,%ax
80102120:	89 ca                	mov    %ecx,%edx
80102122:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102123:	83 e0 c0             	and    $0xffffffc0,%eax
80102126:	3c 40                	cmp    $0x40,%al
80102128:	75 f6                	jne    80102120 <idestart+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010212a:	31 ff                	xor    %edi,%edi
8010212c:	ba f6 03 00 00       	mov    $0x3f6,%edx
80102131:	89 f8                	mov    %edi,%eax
80102133:	ee                   	out    %al,(%dx)
80102134:	b8 01 00 00 00       	mov    $0x1,%eax
80102139:	ba f2 01 00 00       	mov    $0x1f2,%edx
8010213e:	ee                   	out    %al,(%dx)
8010213f:	ba f3 01 00 00       	mov    $0x1f3,%edx
80102144:	89 f0                	mov    %esi,%eax
80102146:	ee                   	out    %al,(%dx)

  idewait(0);
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80102147:	89 f0                	mov    %esi,%eax
80102149:	ba f4 01 00 00       	mov    $0x1f4,%edx
8010214e:	c1 f8 08             	sar    $0x8,%eax
80102151:	ee                   	out    %al,(%dx)
80102152:	ba f5 01 00 00       	mov    $0x1f5,%edx
80102157:	89 f8                	mov    %edi,%eax
80102159:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010215a:	0f b6 43 04          	movzbl 0x4(%ebx),%eax
8010215e:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102163:	c1 e0 04             	shl    $0x4,%eax
80102166:	83 e0 10             	and    $0x10,%eax
80102169:	83 c8 e0             	or     $0xffffffe0,%eax
8010216c:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
8010216d:	f6 03 04             	testb  $0x4,(%ebx)
80102170:	75 16                	jne    80102188 <idestart+0x98>
80102172:	b8 20 00 00 00       	mov    $0x20,%eax
80102177:	89 ca                	mov    %ecx,%edx
80102179:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
8010217a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010217d:	5b                   	pop    %ebx
8010217e:	5e                   	pop    %esi
8010217f:	5f                   	pop    %edi
80102180:	5d                   	pop    %ebp
80102181:	c3                   	ret    
80102182:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80102188:	b8 30 00 00 00       	mov    $0x30,%eax
8010218d:	89 ca                	mov    %ecx,%edx
8010218f:	ee                   	out    %al,(%dx)
  asm volatile("cld; rep outsl" :
80102190:	b9 80 00 00 00       	mov    $0x80,%ecx
    outsl(0x1f0, b->data, BSIZE/4);
80102195:	8d 73 5c             	lea    0x5c(%ebx),%esi
80102198:	ba f0 01 00 00       	mov    $0x1f0,%edx
8010219d:	fc                   	cld    
8010219e:	f3 6f                	rep outsl %ds:(%esi),(%dx)
}
801021a0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801021a3:	5b                   	pop    %ebx
801021a4:	5e                   	pop    %esi
801021a5:	5f                   	pop    %edi
801021a6:	5d                   	pop    %ebp
801021a7:	c3                   	ret    
    panic("incorrect blockno");
801021a8:	83 ec 0c             	sub    $0xc,%esp
801021ab:	68 74 7d 10 80       	push   $0x80107d74
801021b0:	e8 cb e1 ff ff       	call   80100380 <panic>
    panic("idestart");
801021b5:	83 ec 0c             	sub    $0xc,%esp
801021b8:	68 6b 7d 10 80       	push   $0x80107d6b
801021bd:	e8 be e1 ff ff       	call   80100380 <panic>
801021c2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801021c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801021d0 <ideinit>:
{
801021d0:	55                   	push   %ebp
801021d1:	89 e5                	mov    %esp,%ebp
801021d3:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
801021d6:	68 86 7d 10 80       	push   $0x80107d86
801021db:	68 00 26 11 80       	push   $0x80112600
801021e0:	e8 bb 27 00 00       	call   801049a0 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
801021e5:	58                   	pop    %eax
801021e6:	a1 84 27 11 80       	mov    0x80112784,%eax
801021eb:	5a                   	pop    %edx
801021ec:	83 e8 01             	sub    $0x1,%eax
801021ef:	50                   	push   %eax
801021f0:	6a 0e                	push   $0xe
801021f2:	e8 99 02 00 00       	call   80102490 <ioapicenable>
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
801021f7:	83 c4 10             	add    $0x10,%esp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801021fa:	ba f7 01 00 00       	mov    $0x1f7,%edx
801021ff:	90                   	nop
80102200:	ec                   	in     (%dx),%al
80102201:	83 e0 c0             	and    $0xffffffc0,%eax
80102204:	3c 40                	cmp    $0x40,%al
80102206:	75 f8                	jne    80102200 <ideinit+0x30>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102208:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
8010220d:	ba f6 01 00 00       	mov    $0x1f6,%edx
80102212:	ee                   	out    %al,(%dx)
80102213:	b9 e8 03 00 00       	mov    $0x3e8,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102218:	ba f7 01 00 00       	mov    $0x1f7,%edx
8010221d:	eb 06                	jmp    80102225 <ideinit+0x55>
8010221f:	90                   	nop
  for(i=0; i<1000; i++){
80102220:	83 e9 01             	sub    $0x1,%ecx
80102223:	74 0f                	je     80102234 <ideinit+0x64>
80102225:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80102226:	84 c0                	test   %al,%al
80102228:	74 f6                	je     80102220 <ideinit+0x50>
      havedisk1 = 1;
8010222a:	c7 05 e0 25 11 80 01 	movl   $0x1,0x801125e0
80102231:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102234:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80102239:	ba f6 01 00 00       	mov    $0x1f6,%edx
8010223e:	ee                   	out    %al,(%dx)
}
8010223f:	c9                   	leave  
80102240:	c3                   	ret    
80102241:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102248:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010224f:	90                   	nop

80102250 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80102250:	55                   	push   %ebp
80102251:	89 e5                	mov    %esp,%ebp
80102253:	57                   	push   %edi
80102254:	56                   	push   %esi
80102255:	53                   	push   %ebx
80102256:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102259:	68 00 26 11 80       	push   $0x80112600
8010225e:	e8 0d 29 00 00       	call   80104b70 <acquire>

  if((b = idequeue) == 0){
80102263:	8b 1d e4 25 11 80    	mov    0x801125e4,%ebx
80102269:	83 c4 10             	add    $0x10,%esp
8010226c:	85 db                	test   %ebx,%ebx
8010226e:	74 63                	je     801022d3 <ideintr+0x83>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80102270:	8b 43 58             	mov    0x58(%ebx),%eax
80102273:	a3 e4 25 11 80       	mov    %eax,0x801125e4

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102278:	8b 33                	mov    (%ebx),%esi
8010227a:	f7 c6 04 00 00 00    	test   $0x4,%esi
80102280:	75 2f                	jne    801022b1 <ideintr+0x61>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102282:	ba f7 01 00 00       	mov    $0x1f7,%edx
80102287:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010228e:	66 90                	xchg   %ax,%ax
80102290:	ec                   	in     (%dx),%al
  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80102291:	89 c1                	mov    %eax,%ecx
80102293:	83 e1 c0             	and    $0xffffffc0,%ecx
80102296:	80 f9 40             	cmp    $0x40,%cl
80102299:	75 f5                	jne    80102290 <ideintr+0x40>
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
8010229b:	a8 21                	test   $0x21,%al
8010229d:	75 12                	jne    801022b1 <ideintr+0x61>
    insl(0x1f0, b->data, BSIZE/4);
8010229f:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
801022a2:	b9 80 00 00 00       	mov    $0x80,%ecx
801022a7:	ba f0 01 00 00       	mov    $0x1f0,%edx
801022ac:	fc                   	cld    
801022ad:	f3 6d                	rep insl (%dx),%es:(%edi)

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
801022af:	8b 33                	mov    (%ebx),%esi
  b->flags &= ~B_DIRTY;
801022b1:	83 e6 fb             	and    $0xfffffffb,%esi
  wakeup(b);
801022b4:	83 ec 0c             	sub    $0xc,%esp
  b->flags &= ~B_DIRTY;
801022b7:	83 ce 02             	or     $0x2,%esi
801022ba:	89 33                	mov    %esi,(%ebx)
  wakeup(b);
801022bc:	53                   	push   %ebx
801022bd:	e8 be 1e 00 00       	call   80104180 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
801022c2:	a1 e4 25 11 80       	mov    0x801125e4,%eax
801022c7:	83 c4 10             	add    $0x10,%esp
801022ca:	85 c0                	test   %eax,%eax
801022cc:	74 05                	je     801022d3 <ideintr+0x83>
    idestart(idequeue);
801022ce:	e8 1d fe ff ff       	call   801020f0 <idestart>
    release(&idelock);
801022d3:	83 ec 0c             	sub    $0xc,%esp
801022d6:	68 00 26 11 80       	push   $0x80112600
801022db:	e8 30 28 00 00       	call   80104b10 <release>

  release(&idelock);
}
801022e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022e3:	5b                   	pop    %ebx
801022e4:	5e                   	pop    %esi
801022e5:	5f                   	pop    %edi
801022e6:	5d                   	pop    %ebp
801022e7:	c3                   	ret    
801022e8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801022ef:	90                   	nop

801022f0 <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801022f0:	55                   	push   %ebp
801022f1:	89 e5                	mov    %esp,%ebp
801022f3:	53                   	push   %ebx
801022f4:	83 ec 10             	sub    $0x10,%esp
801022f7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
801022fa:	8d 43 0c             	lea    0xc(%ebx),%eax
801022fd:	50                   	push   %eax
801022fe:	e8 4d 26 00 00       	call   80104950 <holdingsleep>
80102303:	83 c4 10             	add    $0x10,%esp
80102306:	85 c0                	test   %eax,%eax
80102308:	0f 84 c3 00 00 00    	je     801023d1 <iderw+0xe1>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
8010230e:	8b 03                	mov    (%ebx),%eax
80102310:	83 e0 06             	and    $0x6,%eax
80102313:	83 f8 02             	cmp    $0x2,%eax
80102316:	0f 84 a8 00 00 00    	je     801023c4 <iderw+0xd4>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
8010231c:	8b 53 04             	mov    0x4(%ebx),%edx
8010231f:	85 d2                	test   %edx,%edx
80102321:	74 0d                	je     80102330 <iderw+0x40>
80102323:	a1 e0 25 11 80       	mov    0x801125e0,%eax
80102328:	85 c0                	test   %eax,%eax
8010232a:	0f 84 87 00 00 00    	je     801023b7 <iderw+0xc7>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80102330:	83 ec 0c             	sub    $0xc,%esp
80102333:	68 00 26 11 80       	push   $0x80112600
80102338:	e8 33 28 00 00       	call   80104b70 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
8010233d:	a1 e4 25 11 80       	mov    0x801125e4,%eax
  b->qnext = 0;
80102342:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102349:	83 c4 10             	add    $0x10,%esp
8010234c:	85 c0                	test   %eax,%eax
8010234e:	74 60                	je     801023b0 <iderw+0xc0>
80102350:	89 c2                	mov    %eax,%edx
80102352:	8b 40 58             	mov    0x58(%eax),%eax
80102355:	85 c0                	test   %eax,%eax
80102357:	75 f7                	jne    80102350 <iderw+0x60>
80102359:	83 c2 58             	add    $0x58,%edx
    ;
  *pp = b;
8010235c:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
8010235e:	39 1d e4 25 11 80    	cmp    %ebx,0x801125e4
80102364:	74 3a                	je     801023a0 <iderw+0xb0>
    idestart(b);

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80102366:	8b 03                	mov    (%ebx),%eax
80102368:	83 e0 06             	and    $0x6,%eax
8010236b:	83 f8 02             	cmp    $0x2,%eax
8010236e:	74 1b                	je     8010238b <iderw+0x9b>
    sleep(b, &idelock);
80102370:	83 ec 08             	sub    $0x8,%esp
80102373:	68 00 26 11 80       	push   $0x80112600
80102378:	53                   	push   %ebx
80102379:	e8 42 1d 00 00       	call   801040c0 <sleep>
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
8010237e:	8b 03                	mov    (%ebx),%eax
80102380:	83 c4 10             	add    $0x10,%esp
80102383:	83 e0 06             	and    $0x6,%eax
80102386:	83 f8 02             	cmp    $0x2,%eax
80102389:	75 e5                	jne    80102370 <iderw+0x80>
  }


  release(&idelock);
8010238b:	c7 45 08 00 26 11 80 	movl   $0x80112600,0x8(%ebp)
}
80102392:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102395:	c9                   	leave  
  release(&idelock);
80102396:	e9 75 27 00 00       	jmp    80104b10 <release>
8010239b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010239f:	90                   	nop
    idestart(b);
801023a0:	89 d8                	mov    %ebx,%eax
801023a2:	e8 49 fd ff ff       	call   801020f0 <idestart>
801023a7:	eb bd                	jmp    80102366 <iderw+0x76>
801023a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
801023b0:	ba e4 25 11 80       	mov    $0x801125e4,%edx
801023b5:	eb a5                	jmp    8010235c <iderw+0x6c>
    panic("iderw: ide disk 1 not present");
801023b7:	83 ec 0c             	sub    $0xc,%esp
801023ba:	68 b5 7d 10 80       	push   $0x80107db5
801023bf:	e8 bc df ff ff       	call   80100380 <panic>
    panic("iderw: nothing to do");
801023c4:	83 ec 0c             	sub    $0xc,%esp
801023c7:	68 a0 7d 10 80       	push   $0x80107da0
801023cc:	e8 af df ff ff       	call   80100380 <panic>
    panic("iderw: buf not locked");
801023d1:	83 ec 0c             	sub    $0xc,%esp
801023d4:	68 8a 7d 10 80       	push   $0x80107d8a
801023d9:	e8 a2 df ff ff       	call   80100380 <panic>
801023de:	66 90                	xchg   %ax,%ax

801023e0 <ioapicinit>:
  ioapic->data = data;
}

void
ioapicinit(void)
{
801023e0:	55                   	push   %ebp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
801023e1:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
801023e8:	00 c0 fe 
{
801023eb:	89 e5                	mov    %esp,%ebp
801023ed:	56                   	push   %esi
801023ee:	53                   	push   %ebx
  ioapic->reg = reg;
801023ef:	c7 05 00 00 c0 fe 01 	movl   $0x1,0xfec00000
801023f6:	00 00 00 
  return ioapic->data;
801023f9:	8b 15 34 26 11 80    	mov    0x80112634,%edx
801023ff:	8b 72 10             	mov    0x10(%edx),%esi
  ioapic->reg = reg;
80102402:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
  return ioapic->data;
80102408:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
  id = ioapicread(REG_ID) >> 24;
  if(id != ioapicid)
8010240e:	0f b6 15 80 27 11 80 	movzbl 0x80112780,%edx
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102415:	c1 ee 10             	shr    $0x10,%esi
80102418:	89 f0                	mov    %esi,%eax
8010241a:	0f b6 f0             	movzbl %al,%esi
  return ioapic->data;
8010241d:	8b 41 10             	mov    0x10(%ecx),%eax
  id = ioapicread(REG_ID) >> 24;
80102420:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80102423:	39 c2                	cmp    %eax,%edx
80102425:	74 16                	je     8010243d <ioapicinit+0x5d>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102427:	83 ec 0c             	sub    $0xc,%esp
8010242a:	68 d4 7d 10 80       	push   $0x80107dd4
8010242f:	e8 6c e2 ff ff       	call   801006a0 <cprintf>
  ioapic->reg = reg;
80102434:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
8010243a:	83 c4 10             	add    $0x10,%esp
8010243d:	83 c6 21             	add    $0x21,%esi
{
80102440:	ba 10 00 00 00       	mov    $0x10,%edx
80102445:	b8 20 00 00 00       	mov    $0x20,%eax
8010244a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  ioapic->reg = reg;
80102450:	89 11                	mov    %edx,(%ecx)

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102452:	89 c3                	mov    %eax,%ebx
  ioapic->data = data;
80102454:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  for(i = 0; i <= maxintr; i++){
8010245a:	83 c0 01             	add    $0x1,%eax
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
8010245d:	81 cb 00 00 01 00    	or     $0x10000,%ebx
  ioapic->data = data;
80102463:	89 59 10             	mov    %ebx,0x10(%ecx)
  ioapic->reg = reg;
80102466:	8d 5a 01             	lea    0x1(%edx),%ebx
  for(i = 0; i <= maxintr; i++){
80102469:	83 c2 02             	add    $0x2,%edx
  ioapic->reg = reg;
8010246c:	89 19                	mov    %ebx,(%ecx)
  ioapic->data = data;
8010246e:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80102474:	c7 41 10 00 00 00 00 	movl   $0x0,0x10(%ecx)
  for(i = 0; i <= maxintr; i++){
8010247b:	39 f0                	cmp    %esi,%eax
8010247d:	75 d1                	jne    80102450 <ioapicinit+0x70>
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
8010247f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102482:	5b                   	pop    %ebx
80102483:	5e                   	pop    %esi
80102484:	5d                   	pop    %ebp
80102485:	c3                   	ret    
80102486:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010248d:	8d 76 00             	lea    0x0(%esi),%esi

80102490 <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102490:	55                   	push   %ebp
  ioapic->reg = reg;
80102491:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
{
80102497:	89 e5                	mov    %esp,%ebp
80102499:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
8010249c:	8d 50 20             	lea    0x20(%eax),%edx
8010249f:	8d 44 00 10          	lea    0x10(%eax,%eax,1),%eax
  ioapic->reg = reg;
801024a3:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801024a5:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801024ab:	83 c0 01             	add    $0x1,%eax
  ioapic->data = data;
801024ae:	89 51 10             	mov    %edx,0x10(%ecx)
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801024b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  ioapic->reg = reg;
801024b4:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
801024b6:	a1 34 26 11 80       	mov    0x80112634,%eax
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
801024bb:	c1 e2 18             	shl    $0x18,%edx
  ioapic->data = data;
801024be:	89 50 10             	mov    %edx,0x10(%eax)
}
801024c1:	5d                   	pop    %ebp
801024c2:	c3                   	ret    
801024c3:	66 90                	xchg   %ax,%ax
801024c5:	66 90                	xchg   %ax,%ax
801024c7:	66 90                	xchg   %ax,%ax
801024c9:	66 90                	xchg   %ax,%ax
801024cb:	66 90                	xchg   %ax,%ax
801024cd:	66 90                	xchg   %ax,%ax
801024cf:	90                   	nop

801024d0 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
801024d0:	55                   	push   %ebp
801024d1:	89 e5                	mov    %esp,%ebp
801024d3:	53                   	push   %ebx
801024d4:	83 ec 04             	sub    $0x4,%esp
801024d7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
801024da:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
801024e0:	75 76                	jne    80102558 <kfree+0x88>
801024e2:	81 fb f0 b5 51 80    	cmp    $0x8051b5f0,%ebx
801024e8:	72 6e                	jb     80102558 <kfree+0x88>
801024ea:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801024f0:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
801024f5:	77 61                	ja     80102558 <kfree+0x88>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
801024f7:	83 ec 04             	sub    $0x4,%esp
801024fa:	68 00 10 00 00       	push   $0x1000
801024ff:	6a 01                	push   $0x1
80102501:	53                   	push   %ebx
80102502:	e8 29 27 00 00       	call   80104c30 <memset>

  if(kmem.use_lock)
80102507:	8b 15 74 26 11 80    	mov    0x80112674,%edx
8010250d:	83 c4 10             	add    $0x10,%esp
80102510:	85 d2                	test   %edx,%edx
80102512:	75 1c                	jne    80102530 <kfree+0x60>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80102514:	a1 78 26 11 80       	mov    0x80112678,%eax
80102519:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
  if(kmem.use_lock)
8010251b:	a1 74 26 11 80       	mov    0x80112674,%eax
  kmem.freelist = r;
80102520:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  if(kmem.use_lock)
80102526:	85 c0                	test   %eax,%eax
80102528:	75 1e                	jne    80102548 <kfree+0x78>
    release(&kmem.lock);
}
8010252a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010252d:	c9                   	leave  
8010252e:	c3                   	ret    
8010252f:	90                   	nop
    acquire(&kmem.lock);
80102530:	83 ec 0c             	sub    $0xc,%esp
80102533:	68 40 26 11 80       	push   $0x80112640
80102538:	e8 33 26 00 00       	call   80104b70 <acquire>
8010253d:	83 c4 10             	add    $0x10,%esp
80102540:	eb d2                	jmp    80102514 <kfree+0x44>
80102542:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    release(&kmem.lock);
80102548:	c7 45 08 40 26 11 80 	movl   $0x80112640,0x8(%ebp)
}
8010254f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102552:	c9                   	leave  
    release(&kmem.lock);
80102553:	e9 b8 25 00 00       	jmp    80104b10 <release>
    panic("kfree");
80102558:	83 ec 0c             	sub    $0xc,%esp
8010255b:	68 06 7e 10 80       	push   $0x80107e06
80102560:	e8 1b de ff ff       	call   80100380 <panic>
80102565:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010256c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102570 <freerange>:
{
80102570:	55                   	push   %ebp
80102571:	89 e5                	mov    %esp,%ebp
80102573:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
80102574:	8b 45 08             	mov    0x8(%ebp),%eax
{
80102577:	8b 75 0c             	mov    0xc(%ebp),%esi
8010257a:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010257b:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102581:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102587:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010258d:	39 de                	cmp    %ebx,%esi
8010258f:	72 23                	jb     801025b4 <freerange+0x44>
80102591:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
80102598:	83 ec 0c             	sub    $0xc,%esp
8010259b:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025a1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801025a7:	50                   	push   %eax
801025a8:	e8 23 ff ff ff       	call   801024d0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025ad:	83 c4 10             	add    $0x10,%esp
801025b0:	39 f3                	cmp    %esi,%ebx
801025b2:	76 e4                	jbe    80102598 <freerange+0x28>
}
801025b4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801025b7:	5b                   	pop    %ebx
801025b8:	5e                   	pop    %esi
801025b9:	5d                   	pop    %ebp
801025ba:	c3                   	ret    
801025bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801025bf:	90                   	nop

801025c0 <kinit2>:
{
801025c0:	55                   	push   %ebp
801025c1:	89 e5                	mov    %esp,%ebp
801025c3:	56                   	push   %esi
  p = (char*)PGROUNDUP((uint)vstart);
801025c4:	8b 45 08             	mov    0x8(%ebp),%eax
{
801025c7:	8b 75 0c             	mov    0xc(%ebp),%esi
801025ca:	53                   	push   %ebx
  p = (char*)PGROUNDUP((uint)vstart);
801025cb:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801025d1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025d7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801025dd:	39 de                	cmp    %ebx,%esi
801025df:	72 23                	jb     80102604 <kinit2+0x44>
801025e1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    kfree(p);
801025e8:	83 ec 0c             	sub    $0xc,%esp
801025eb:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025f1:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
801025f7:	50                   	push   %eax
801025f8:	e8 d3 fe ff ff       	call   801024d0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801025fd:	83 c4 10             	add    $0x10,%esp
80102600:	39 de                	cmp    %ebx,%esi
80102602:	73 e4                	jae    801025e8 <kinit2+0x28>
  kmem.use_lock = 1;
80102604:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
8010260b:	00 00 00 
}
8010260e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102611:	5b                   	pop    %ebx
80102612:	5e                   	pop    %esi
80102613:	5d                   	pop    %ebp
80102614:	c3                   	ret    
80102615:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010261c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80102620 <kinit1>:
{
80102620:	55                   	push   %ebp
80102621:	89 e5                	mov    %esp,%ebp
80102623:	56                   	push   %esi
80102624:	53                   	push   %ebx
80102625:	8b 75 0c             	mov    0xc(%ebp),%esi
  initlock(&kmem.lock, "kmem");
80102628:	83 ec 08             	sub    $0x8,%esp
8010262b:	68 0c 7e 10 80       	push   $0x80107e0c
80102630:	68 40 26 11 80       	push   $0x80112640
80102635:	e8 66 23 00 00       	call   801049a0 <initlock>
  p = (char*)PGROUNDUP((uint)vstart);
8010263a:	8b 45 08             	mov    0x8(%ebp),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010263d:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102640:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
80102647:	00 00 00 
  p = (char*)PGROUNDUP((uint)vstart);
8010264a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80102650:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102656:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010265c:	39 de                	cmp    %ebx,%esi
8010265e:	72 1c                	jb     8010267c <kinit1+0x5c>
    kfree(p);
80102660:	83 ec 0c             	sub    $0xc,%esp
80102663:	8d 83 00 f0 ff ff    	lea    -0x1000(%ebx),%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102669:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    kfree(p);
8010266f:	50                   	push   %eax
80102670:	e8 5b fe ff ff       	call   801024d0 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102675:	83 c4 10             	add    $0x10,%esp
80102678:	39 de                	cmp    %ebx,%esi
8010267a:	73 e4                	jae    80102660 <kinit1+0x40>
}
8010267c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010267f:	5b                   	pop    %ebx
80102680:	5e                   	pop    %esi
80102681:	5d                   	pop    %ebp
80102682:	c3                   	ret    
80102683:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010268a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102690 <kalloc>:
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
80102690:	a1 74 26 11 80       	mov    0x80112674,%eax
80102695:	85 c0                	test   %eax,%eax
80102697:	75 1f                	jne    801026b8 <kalloc+0x28>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102699:	a1 78 26 11 80       	mov    0x80112678,%eax
  if(r)
8010269e:	85 c0                	test   %eax,%eax
801026a0:	74 0e                	je     801026b0 <kalloc+0x20>
    kmem.freelist = r->next;
801026a2:	8b 10                	mov    (%eax),%edx
801026a4:	89 15 78 26 11 80    	mov    %edx,0x80112678
  if(kmem.use_lock)
801026aa:	c3                   	ret    
801026ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801026af:	90                   	nop
    release(&kmem.lock);
  return (char*)r;
}
801026b0:	c3                   	ret    
801026b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
{
801026b8:	55                   	push   %ebp
801026b9:	89 e5                	mov    %esp,%ebp
801026bb:	83 ec 24             	sub    $0x24,%esp
    acquire(&kmem.lock);
801026be:	68 40 26 11 80       	push   $0x80112640
801026c3:	e8 a8 24 00 00       	call   80104b70 <acquire>
  r = kmem.freelist;
801026c8:	a1 78 26 11 80       	mov    0x80112678,%eax
  if(kmem.use_lock)
801026cd:	8b 15 74 26 11 80    	mov    0x80112674,%edx
  if(r)
801026d3:	83 c4 10             	add    $0x10,%esp
801026d6:	85 c0                	test   %eax,%eax
801026d8:	74 08                	je     801026e2 <kalloc+0x52>
    kmem.freelist = r->next;
801026da:	8b 08                	mov    (%eax),%ecx
801026dc:	89 0d 78 26 11 80    	mov    %ecx,0x80112678
  if(kmem.use_lock)
801026e2:	85 d2                	test   %edx,%edx
801026e4:	74 16                	je     801026fc <kalloc+0x6c>
    release(&kmem.lock);
801026e6:	83 ec 0c             	sub    $0xc,%esp
801026e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
801026ec:	68 40 26 11 80       	push   $0x80112640
801026f1:	e8 1a 24 00 00       	call   80104b10 <release>
  return (char*)r;
801026f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
    release(&kmem.lock);
801026f9:	83 c4 10             	add    $0x10,%esp
}
801026fc:	c9                   	leave  
801026fd:	c3                   	ret    
801026fe:	66 90                	xchg   %ax,%ax

80102700 <kbdgetc>:
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102700:	ba 64 00 00 00       	mov    $0x64,%edx
80102705:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102706:	a8 01                	test   $0x1,%al
80102708:	0f 84 c2 00 00 00    	je     801027d0 <kbdgetc+0xd0>
{
8010270e:	55                   	push   %ebp
8010270f:	ba 60 00 00 00       	mov    $0x60,%edx
80102714:	89 e5                	mov    %esp,%ebp
80102716:	53                   	push   %ebx
80102717:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);

  if(data == 0xE0){
    shift |= E0ESC;
80102718:	8b 1d 7c 26 11 80    	mov    0x8011267c,%ebx
  data = inb(KBDATAP);
8010271e:	0f b6 c8             	movzbl %al,%ecx
  if(data == 0xE0){
80102721:	3c e0                	cmp    $0xe0,%al
80102723:	74 5b                	je     80102780 <kbdgetc+0x80>
    return 0;
  } else if(data & 0x80){
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102725:	89 da                	mov    %ebx,%edx
80102727:	83 e2 40             	and    $0x40,%edx
  } else if(data & 0x80){
8010272a:	84 c0                	test   %al,%al
8010272c:	78 62                	js     80102790 <kbdgetc+0x90>
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
8010272e:	85 d2                	test   %edx,%edx
80102730:	74 09                	je     8010273b <kbdgetc+0x3b>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102732:	83 c8 80             	or     $0xffffff80,%eax
    shift &= ~E0ESC;
80102735:	83 e3 bf             	and    $0xffffffbf,%ebx
    data |= 0x80;
80102738:	0f b6 c8             	movzbl %al,%ecx
  }

  shift |= shiftcode[data];
8010273b:	0f b6 91 40 7f 10 80 	movzbl -0x7fef80c0(%ecx),%edx
  shift ^= togglecode[data];
80102742:	0f b6 81 40 7e 10 80 	movzbl -0x7fef81c0(%ecx),%eax
  shift |= shiftcode[data];
80102749:	09 da                	or     %ebx,%edx
  shift ^= togglecode[data];
8010274b:	31 c2                	xor    %eax,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010274d:	89 d0                	mov    %edx,%eax
  shift ^= togglecode[data];
8010274f:	89 15 7c 26 11 80    	mov    %edx,0x8011267c
  c = charcode[shift & (CTL | SHIFT)][data];
80102755:	83 e0 03             	and    $0x3,%eax
  if(shift & CAPSLOCK){
80102758:	83 e2 08             	and    $0x8,%edx
  c = charcode[shift & (CTL | SHIFT)][data];
8010275b:	8b 04 85 20 7e 10 80 	mov    -0x7fef81e0(,%eax,4),%eax
80102762:	0f b6 04 08          	movzbl (%eax,%ecx,1),%eax
  if(shift & CAPSLOCK){
80102766:	74 0b                	je     80102773 <kbdgetc+0x73>
    if('a' <= c && c <= 'z')
80102768:	8d 50 9f             	lea    -0x61(%eax),%edx
8010276b:	83 fa 19             	cmp    $0x19,%edx
8010276e:	77 48                	ja     801027b8 <kbdgetc+0xb8>
      c += 'A' - 'a';
80102770:	83 e8 20             	sub    $0x20,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102773:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102776:	c9                   	leave  
80102777:	c3                   	ret    
80102778:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010277f:	90                   	nop
    shift |= E0ESC;
80102780:	83 cb 40             	or     $0x40,%ebx
    return 0;
80102783:	31 c0                	xor    %eax,%eax
    shift |= E0ESC;
80102785:	89 1d 7c 26 11 80    	mov    %ebx,0x8011267c
}
8010278b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010278e:	c9                   	leave  
8010278f:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102790:	83 e0 7f             	and    $0x7f,%eax
80102793:	85 d2                	test   %edx,%edx
80102795:	0f 44 c8             	cmove  %eax,%ecx
    shift &= ~(shiftcode[data] | E0ESC);
80102798:	0f b6 81 40 7f 10 80 	movzbl -0x7fef80c0(%ecx),%eax
8010279f:	83 c8 40             	or     $0x40,%eax
801027a2:	0f b6 c0             	movzbl %al,%eax
801027a5:	f7 d0                	not    %eax
801027a7:	21 d8                	and    %ebx,%eax
}
801027a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    shift &= ~(shiftcode[data] | E0ESC);
801027ac:	a3 7c 26 11 80       	mov    %eax,0x8011267c
    return 0;
801027b1:	31 c0                	xor    %eax,%eax
}
801027b3:	c9                   	leave  
801027b4:	c3                   	ret    
801027b5:	8d 76 00             	lea    0x0(%esi),%esi
    else if('A' <= c && c <= 'Z')
801027b8:	8d 48 bf             	lea    -0x41(%eax),%ecx
      c += 'a' - 'A';
801027bb:	8d 50 20             	lea    0x20(%eax),%edx
}
801027be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027c1:	c9                   	leave  
      c += 'a' - 'A';
801027c2:	83 f9 1a             	cmp    $0x1a,%ecx
801027c5:	0f 42 c2             	cmovb  %edx,%eax
}
801027c8:	c3                   	ret    
801027c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
801027d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801027d5:	c3                   	ret    
801027d6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801027dd:	8d 76 00             	lea    0x0(%esi),%esi

801027e0 <kbdintr>:

void
kbdintr(void)
{
801027e0:	55                   	push   %ebp
801027e1:	89 e5                	mov    %esp,%ebp
801027e3:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801027e6:	68 00 27 10 80       	push   $0x80102700
801027eb:	e8 90 e0 ff ff       	call   80100880 <consoleintr>
}
801027f0:	83 c4 10             	add    $0x10,%esp
801027f3:	c9                   	leave  
801027f4:	c3                   	ret    
801027f5:	66 90                	xchg   %ax,%ax
801027f7:	66 90                	xchg   %ax,%ax
801027f9:	66 90                	xchg   %ax,%ax
801027fb:	66 90                	xchg   %ax,%ax
801027fd:	66 90                	xchg   %ax,%ax
801027ff:	90                   	nop

80102800 <lapicinit>:
}

void
lapicinit(void)
{
  if(!lapic)
80102800:	a1 80 26 11 80       	mov    0x80112680,%eax
80102805:	85 c0                	test   %eax,%eax
80102807:	0f 84 cb 00 00 00    	je     801028d8 <lapicinit+0xd8>
  lapic[index] = value;
8010280d:	c7 80 f0 00 00 00 3f 	movl   $0x13f,0xf0(%eax)
80102814:	01 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102817:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010281a:	c7 80 e0 03 00 00 0b 	movl   $0xb,0x3e0(%eax)
80102821:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102824:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102827:	c7 80 20 03 00 00 20 	movl   $0x20020,0x320(%eax)
8010282e:	00 02 00 
  lapic[ID];  // wait for write to finish, by reading
80102831:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102834:	c7 80 80 03 00 00 80 	movl   $0x989680,0x380(%eax)
8010283b:	96 98 00 
  lapic[ID];  // wait for write to finish, by reading
8010283e:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102841:	c7 80 50 03 00 00 00 	movl   $0x10000,0x350(%eax)
80102848:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
8010284b:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010284e:	c7 80 60 03 00 00 00 	movl   $0x10000,0x360(%eax)
80102855:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
80102858:	8b 50 20             	mov    0x20(%eax),%edx
  lapicw(LINT0, MASKED);
  lapicw(LINT1, MASKED);

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010285b:	8b 50 30             	mov    0x30(%eax),%edx
8010285e:	c1 ea 10             	shr    $0x10,%edx
80102861:	81 e2 fc 00 00 00    	and    $0xfc,%edx
80102867:	75 77                	jne    801028e0 <lapicinit+0xe0>
  lapic[index] = value;
80102869:	c7 80 70 03 00 00 33 	movl   $0x33,0x370(%eax)
80102870:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102873:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102876:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010287d:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102880:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102883:	c7 80 80 02 00 00 00 	movl   $0x0,0x280(%eax)
8010288a:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010288d:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
80102890:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102897:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
8010289a:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
8010289d:	c7 80 10 03 00 00 00 	movl   $0x0,0x310(%eax)
801028a4:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801028a7:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801028aa:	c7 80 00 03 00 00 00 	movl   $0x88500,0x300(%eax)
801028b1:	85 08 00 
  lapic[ID];  // wait for write to finish, by reading
801028b4:	8b 50 20             	mov    0x20(%eax),%edx
801028b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801028be:	66 90                	xchg   %ax,%ax
  lapicw(EOI, 0);

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
  lapicw(ICRLO, BCAST | INIT | LEVEL);
  while(lapic[ICRLO] & DELIVS)
801028c0:	8b 90 00 03 00 00    	mov    0x300(%eax),%edx
801028c6:	80 e6 10             	and    $0x10,%dh
801028c9:	75 f5                	jne    801028c0 <lapicinit+0xc0>
  lapic[index] = value;
801028cb:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
801028d2:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
801028d5:	8b 40 20             	mov    0x20(%eax),%eax
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
801028d8:	c3                   	ret    
801028d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  lapic[index] = value;
801028e0:	c7 80 40 03 00 00 00 	movl   $0x10000,0x340(%eax)
801028e7:	00 01 00 
  lapic[ID];  // wait for write to finish, by reading
801028ea:	8b 50 20             	mov    0x20(%eax),%edx
}
801028ed:	e9 77 ff ff ff       	jmp    80102869 <lapicinit+0x69>
801028f2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801028f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102900 <lapicid>:

int
lapicid(void)
{
  if (!lapic)
80102900:	a1 80 26 11 80       	mov    0x80112680,%eax
80102905:	85 c0                	test   %eax,%eax
80102907:	74 07                	je     80102910 <lapicid+0x10>
    return 0;
  return lapic[ID] >> 24;
80102909:	8b 40 20             	mov    0x20(%eax),%eax
8010290c:	c1 e8 18             	shr    $0x18,%eax
8010290f:	c3                   	ret    
    return 0;
80102910:	31 c0                	xor    %eax,%eax
}
80102912:	c3                   	ret    
80102913:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010291a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80102920 <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
  if(lapic)
80102920:	a1 80 26 11 80       	mov    0x80112680,%eax
80102925:	85 c0                	test   %eax,%eax
80102927:	74 0d                	je     80102936 <lapiceoi+0x16>
  lapic[index] = value;
80102929:	c7 80 b0 00 00 00 00 	movl   $0x0,0xb0(%eax)
80102930:	00 00 00 
  lapic[ID];  // wait for write to finish, by reading
80102933:	8b 40 20             	mov    0x20(%eax),%eax
    lapicw(EOI, 0);
}
80102936:	c3                   	ret    
80102937:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010293e:	66 90                	xchg   %ax,%ax

80102940 <microdelay>:
// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
}
80102940:	c3                   	ret    
80102941:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102948:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010294f:	90                   	nop

80102950 <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
80102950:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102951:	b8 0f 00 00 00       	mov    $0xf,%eax
80102956:	ba 70 00 00 00       	mov    $0x70,%edx
8010295b:	89 e5                	mov    %esp,%ebp
8010295d:	53                   	push   %ebx
8010295e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80102961:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102964:	ee                   	out    %al,(%dx)
80102965:	b8 0a 00 00 00       	mov    $0xa,%eax
8010296a:	ba 71 00 00 00       	mov    $0x71,%edx
8010296f:	ee                   	out    %al,(%dx)
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
  outb(CMOS_PORT+1, 0x0A);
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
  wrv[0] = 0;
80102970:	31 c0                	xor    %eax,%eax
  wrv[1] = addr >> 4;

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
80102972:	c1 e3 18             	shl    $0x18,%ebx
  wrv[0] = 0;
80102975:	66 a3 67 04 00 80    	mov    %ax,0x80000467
  wrv[1] = addr >> 4;
8010297b:	89 c8                	mov    %ecx,%eax
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
8010297d:	c1 e9 0c             	shr    $0xc,%ecx
  lapicw(ICRHI, apicid<<24);
80102980:	89 da                	mov    %ebx,%edx
  wrv[1] = addr >> 4;
80102982:	c1 e8 04             	shr    $0x4,%eax
    lapicw(ICRLO, STARTUP | (addr>>12));
80102985:	80 cd 06             	or     $0x6,%ch
  wrv[1] = addr >> 4;
80102988:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapic[index] = value;
8010298e:	a1 80 26 11 80       	mov    0x80112680,%eax
80102993:	89 98 10 03 00 00    	mov    %ebx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102999:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
8010299c:	c7 80 00 03 00 00 00 	movl   $0xc500,0x300(%eax)
801029a3:	c5 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029a6:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801029a9:	c7 80 00 03 00 00 00 	movl   $0x8500,0x300(%eax)
801029b0:	85 00 00 
  lapic[ID];  // wait for write to finish, by reading
801029b3:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801029b6:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029bc:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801029bf:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029c5:	8b 58 20             	mov    0x20(%eax),%ebx
  lapic[index] = value;
801029c8:	89 90 10 03 00 00    	mov    %edx,0x310(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029ce:	8b 50 20             	mov    0x20(%eax),%edx
  lapic[index] = value;
801029d1:	89 88 00 03 00 00    	mov    %ecx,0x300(%eax)
  lapic[ID];  // wait for write to finish, by reading
801029d7:	8b 40 20             	mov    0x20(%eax),%eax
    microdelay(200);
  }
}
801029da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029dd:	c9                   	leave  
801029de:	c3                   	ret    
801029df:	90                   	nop

801029e0 <cmostime>:
}

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801029e0:	55                   	push   %ebp
801029e1:	b8 0b 00 00 00       	mov    $0xb,%eax
801029e6:	ba 70 00 00 00       	mov    $0x70,%edx
801029eb:	89 e5                	mov    %esp,%ebp
801029ed:	57                   	push   %edi
801029ee:	56                   	push   %esi
801029ef:	53                   	push   %ebx
801029f0:	83 ec 4c             	sub    $0x4c,%esp
801029f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801029f4:	ba 71 00 00 00       	mov    $0x71,%edx
801029f9:	ec                   	in     (%dx),%al
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);

  bcd = (sb & (1 << 2)) == 0;
801029fa:	83 e0 04             	and    $0x4,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801029fd:	bb 70 00 00 00       	mov    $0x70,%ebx
80102a02:	88 45 b3             	mov    %al,-0x4d(%ebp)
80102a05:	8d 76 00             	lea    0x0(%esi),%esi
80102a08:	31 c0                	xor    %eax,%eax
80102a0a:	89 da                	mov    %ebx,%edx
80102a0c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a0d:	b9 71 00 00 00       	mov    $0x71,%ecx
80102a12:	89 ca                	mov    %ecx,%edx
80102a14:	ec                   	in     (%dx),%al
80102a15:	88 45 b7             	mov    %al,-0x49(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a18:	89 da                	mov    %ebx,%edx
80102a1a:	b8 02 00 00 00       	mov    $0x2,%eax
80102a1f:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a20:	89 ca                	mov    %ecx,%edx
80102a22:	ec                   	in     (%dx),%al
80102a23:	88 45 b6             	mov    %al,-0x4a(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a26:	89 da                	mov    %ebx,%edx
80102a28:	b8 04 00 00 00       	mov    $0x4,%eax
80102a2d:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a2e:	89 ca                	mov    %ecx,%edx
80102a30:	ec                   	in     (%dx),%al
80102a31:	88 45 b5             	mov    %al,-0x4b(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a34:	89 da                	mov    %ebx,%edx
80102a36:	b8 07 00 00 00       	mov    $0x7,%eax
80102a3b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a3c:	89 ca                	mov    %ecx,%edx
80102a3e:	ec                   	in     (%dx),%al
80102a3f:	88 45 b4             	mov    %al,-0x4c(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a42:	89 da                	mov    %ebx,%edx
80102a44:	b8 08 00 00 00       	mov    $0x8,%eax
80102a49:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a4a:	89 ca                	mov    %ecx,%edx
80102a4c:	ec                   	in     (%dx),%al
80102a4d:	89 c7                	mov    %eax,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a4f:	89 da                	mov    %ebx,%edx
80102a51:	b8 09 00 00 00       	mov    $0x9,%eax
80102a56:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a57:	89 ca                	mov    %ecx,%edx
80102a59:	ec                   	in     (%dx),%al
80102a5a:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a5c:	89 da                	mov    %ebx,%edx
80102a5e:	b8 0a 00 00 00       	mov    $0xa,%eax
80102a63:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a64:	89 ca                	mov    %ecx,%edx
80102a66:	ec                   	in     (%dx),%al

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102a67:	84 c0                	test   %al,%al
80102a69:	78 9d                	js     80102a08 <cmostime+0x28>
  return inb(CMOS_RETURN);
80102a6b:	0f b6 45 b7          	movzbl -0x49(%ebp),%eax
80102a6f:	89 fa                	mov    %edi,%edx
80102a71:	0f b6 fa             	movzbl %dl,%edi
80102a74:	89 f2                	mov    %esi,%edx
80102a76:	89 45 b8             	mov    %eax,-0x48(%ebp)
80102a79:	0f b6 45 b6          	movzbl -0x4a(%ebp),%eax
80102a7d:	0f b6 f2             	movzbl %dl,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102a80:	89 da                	mov    %ebx,%edx
80102a82:	89 7d c8             	mov    %edi,-0x38(%ebp)
80102a85:	89 45 bc             	mov    %eax,-0x44(%ebp)
80102a88:	0f b6 45 b5          	movzbl -0x4b(%ebp),%eax
80102a8c:	89 75 cc             	mov    %esi,-0x34(%ebp)
80102a8f:	89 45 c0             	mov    %eax,-0x40(%ebp)
80102a92:	0f b6 45 b4          	movzbl -0x4c(%ebp),%eax
80102a96:	89 45 c4             	mov    %eax,-0x3c(%ebp)
80102a99:	31 c0                	xor    %eax,%eax
80102a9b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102a9c:	89 ca                	mov    %ecx,%edx
80102a9e:	ec                   	in     (%dx),%al
80102a9f:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102aa2:	89 da                	mov    %ebx,%edx
80102aa4:	89 45 d0             	mov    %eax,-0x30(%ebp)
80102aa7:	b8 02 00 00 00       	mov    $0x2,%eax
80102aac:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102aad:	89 ca                	mov    %ecx,%edx
80102aaf:	ec                   	in     (%dx),%al
80102ab0:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ab3:	89 da                	mov    %ebx,%edx
80102ab5:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80102ab8:	b8 04 00 00 00       	mov    $0x4,%eax
80102abd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102abe:	89 ca                	mov    %ecx,%edx
80102ac0:	ec                   	in     (%dx),%al
80102ac1:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ac4:	89 da                	mov    %ebx,%edx
80102ac6:	89 45 d8             	mov    %eax,-0x28(%ebp)
80102ac9:	b8 07 00 00 00       	mov    $0x7,%eax
80102ace:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102acf:	89 ca                	mov    %ecx,%edx
80102ad1:	ec                   	in     (%dx),%al
80102ad2:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ad5:	89 da                	mov    %ebx,%edx
80102ad7:	89 45 dc             	mov    %eax,-0x24(%ebp)
80102ada:	b8 08 00 00 00       	mov    $0x8,%eax
80102adf:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102ae0:	89 ca                	mov    %ecx,%edx
80102ae2:	ec                   	in     (%dx),%al
80102ae3:	0f b6 c0             	movzbl %al,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ae6:	89 da                	mov    %ebx,%edx
80102ae8:	89 45 e0             	mov    %eax,-0x20(%ebp)
80102aeb:	b8 09 00 00 00       	mov    $0x9,%eax
80102af0:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102af1:	89 ca                	mov    %ecx,%edx
80102af3:	ec                   	in     (%dx),%al
80102af4:	0f b6 c0             	movzbl %al,%eax
        continue;
    fill_rtcdate(&t2);
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102af7:	83 ec 04             	sub    $0x4,%esp
  return inb(CMOS_RETURN);
80102afa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102afd:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102b00:	6a 18                	push   $0x18
80102b02:	50                   	push   %eax
80102b03:	8d 45 b8             	lea    -0x48(%ebp),%eax
80102b06:	50                   	push   %eax
80102b07:	e8 74 21 00 00       	call   80104c80 <memcmp>
80102b0c:	83 c4 10             	add    $0x10,%esp
80102b0f:	85 c0                	test   %eax,%eax
80102b11:	0f 85 f1 fe ff ff    	jne    80102a08 <cmostime+0x28>
      break;
  }

  // convert
  if(bcd) {
80102b17:	80 7d b3 00          	cmpb   $0x0,-0x4d(%ebp)
80102b1b:	75 78                	jne    80102b95 <cmostime+0x1b5>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102b1d:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102b20:	89 c2                	mov    %eax,%edx
80102b22:	83 e0 0f             	and    $0xf,%eax
80102b25:	c1 ea 04             	shr    $0x4,%edx
80102b28:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b2b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b2e:	89 45 b8             	mov    %eax,-0x48(%ebp)
    CONV(minute);
80102b31:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102b34:	89 c2                	mov    %eax,%edx
80102b36:	83 e0 0f             	and    $0xf,%eax
80102b39:	c1 ea 04             	shr    $0x4,%edx
80102b3c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b3f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b42:	89 45 bc             	mov    %eax,-0x44(%ebp)
    CONV(hour  );
80102b45:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102b48:	89 c2                	mov    %eax,%edx
80102b4a:	83 e0 0f             	and    $0xf,%eax
80102b4d:	c1 ea 04             	shr    $0x4,%edx
80102b50:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b53:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b56:	89 45 c0             	mov    %eax,-0x40(%ebp)
    CONV(day   );
80102b59:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102b5c:	89 c2                	mov    %eax,%edx
80102b5e:	83 e0 0f             	and    $0xf,%eax
80102b61:	c1 ea 04             	shr    $0x4,%edx
80102b64:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b67:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b6a:	89 45 c4             	mov    %eax,-0x3c(%ebp)
    CONV(month );
80102b6d:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102b70:	89 c2                	mov    %eax,%edx
80102b72:	83 e0 0f             	and    $0xf,%eax
80102b75:	c1 ea 04             	shr    $0x4,%edx
80102b78:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b7b:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b7e:	89 45 c8             	mov    %eax,-0x38(%ebp)
    CONV(year  );
80102b81:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102b84:	89 c2                	mov    %eax,%edx
80102b86:	83 e0 0f             	and    $0xf,%eax
80102b89:	c1 ea 04             	shr    $0x4,%edx
80102b8c:	8d 14 92             	lea    (%edx,%edx,4),%edx
80102b8f:	8d 04 50             	lea    (%eax,%edx,2),%eax
80102b92:	89 45 cc             	mov    %eax,-0x34(%ebp)
#undef     CONV
  }

  *r = t1;
80102b95:	8b 75 08             	mov    0x8(%ebp),%esi
80102b98:	8b 45 b8             	mov    -0x48(%ebp),%eax
80102b9b:	89 06                	mov    %eax,(%esi)
80102b9d:	8b 45 bc             	mov    -0x44(%ebp),%eax
80102ba0:	89 46 04             	mov    %eax,0x4(%esi)
80102ba3:	8b 45 c0             	mov    -0x40(%ebp),%eax
80102ba6:	89 46 08             	mov    %eax,0x8(%esi)
80102ba9:	8b 45 c4             	mov    -0x3c(%ebp),%eax
80102bac:	89 46 0c             	mov    %eax,0xc(%esi)
80102baf:	8b 45 c8             	mov    -0x38(%ebp),%eax
80102bb2:	89 46 10             	mov    %eax,0x10(%esi)
80102bb5:	8b 45 cc             	mov    -0x34(%ebp),%eax
80102bb8:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102bbb:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102bc2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102bc5:	5b                   	pop    %ebx
80102bc6:	5e                   	pop    %esi
80102bc7:	5f                   	pop    %edi
80102bc8:	5d                   	pop    %ebp
80102bc9:	c3                   	ret    
80102bca:	66 90                	xchg   %ax,%ax
80102bcc:	66 90                	xchg   %ax,%ax
80102bce:	66 90                	xchg   %ax,%ax

80102bd0 <install_trans>:
static void
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102bd0:	8b 0d e8 26 11 80    	mov    0x801126e8,%ecx
80102bd6:	85 c9                	test   %ecx,%ecx
80102bd8:	0f 8e 8a 00 00 00    	jle    80102c68 <install_trans+0x98>
{
80102bde:	55                   	push   %ebp
80102bdf:	89 e5                	mov    %esp,%ebp
80102be1:	57                   	push   %edi
  for (tail = 0; tail < log.lh.n; tail++) {
80102be2:	31 ff                	xor    %edi,%edi
{
80102be4:	56                   	push   %esi
80102be5:	53                   	push   %ebx
80102be6:	83 ec 0c             	sub    $0xc,%esp
80102be9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102bf0:	a1 d4 26 11 80       	mov    0x801126d4,%eax
80102bf5:	83 ec 08             	sub    $0x8,%esp
80102bf8:	01 f8                	add    %edi,%eax
80102bfa:	83 c0 01             	add    $0x1,%eax
80102bfd:	50                   	push   %eax
80102bfe:	ff 35 e4 26 11 80    	push   0x801126e4
80102c04:	e8 c7 d4 ff ff       	call   801000d0 <bread>
80102c09:	89 c6                	mov    %eax,%esi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102c0b:	58                   	pop    %eax
80102c0c:	5a                   	pop    %edx
80102c0d:	ff 34 bd ec 26 11 80 	push   -0x7feed914(,%edi,4)
80102c14:	ff 35 e4 26 11 80    	push   0x801126e4
  for (tail = 0; tail < log.lh.n; tail++) {
80102c1a:	83 c7 01             	add    $0x1,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102c1d:	e8 ae d4 ff ff       	call   801000d0 <bread>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102c22:	83 c4 0c             	add    $0xc,%esp
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102c25:	89 c3                	mov    %eax,%ebx
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102c27:	8d 46 5c             	lea    0x5c(%esi),%eax
80102c2a:	68 00 02 00 00       	push   $0x200
80102c2f:	50                   	push   %eax
80102c30:	8d 43 5c             	lea    0x5c(%ebx),%eax
80102c33:	50                   	push   %eax
80102c34:	e8 97 20 00 00       	call   80104cd0 <memmove>
    bwrite(dbuf);  // write dst to disk
80102c39:	89 1c 24             	mov    %ebx,(%esp)
80102c3c:	e8 6f d5 ff ff       	call   801001b0 <bwrite>
    brelse(lbuf);
80102c41:	89 34 24             	mov    %esi,(%esp)
80102c44:	e8 a7 d5 ff ff       	call   801001f0 <brelse>
    brelse(dbuf);
80102c49:	89 1c 24             	mov    %ebx,(%esp)
80102c4c:	e8 9f d5 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102c51:	83 c4 10             	add    $0x10,%esp
80102c54:	39 3d e8 26 11 80    	cmp    %edi,0x801126e8
80102c5a:	7f 94                	jg     80102bf0 <install_trans+0x20>
  }
}
80102c5c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c5f:	5b                   	pop    %ebx
80102c60:	5e                   	pop    %esi
80102c61:	5f                   	pop    %edi
80102c62:	5d                   	pop    %ebp
80102c63:	c3                   	ret    
80102c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102c68:	c3                   	ret    
80102c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80102c70 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102c70:	55                   	push   %ebp
80102c71:	89 e5                	mov    %esp,%ebp
80102c73:	53                   	push   %ebx
80102c74:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102c77:	ff 35 d4 26 11 80    	push   0x801126d4
80102c7d:	ff 35 e4 26 11 80    	push   0x801126e4
80102c83:	e8 48 d4 ff ff       	call   801000d0 <bread>
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
80102c88:	83 c4 10             	add    $0x10,%esp
  struct buf *buf = bread(log.dev, log.start);
80102c8b:	89 c3                	mov    %eax,%ebx
  hb->n = log.lh.n;
80102c8d:	a1 e8 26 11 80       	mov    0x801126e8,%eax
80102c92:	89 43 5c             	mov    %eax,0x5c(%ebx)
  for (i = 0; i < log.lh.n; i++) {
80102c95:	85 c0                	test   %eax,%eax
80102c97:	7e 19                	jle    80102cb2 <write_head+0x42>
80102c99:	31 d2                	xor    %edx,%edx
80102c9b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102c9f:	90                   	nop
    hb->block[i] = log.lh.block[i];
80102ca0:	8b 0c 95 ec 26 11 80 	mov    -0x7feed914(,%edx,4),%ecx
80102ca7:	89 4c 93 60          	mov    %ecx,0x60(%ebx,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102cab:	83 c2 01             	add    $0x1,%edx
80102cae:	39 d0                	cmp    %edx,%eax
80102cb0:	75 ee                	jne    80102ca0 <write_head+0x30>
  }
  bwrite(buf);
80102cb2:	83 ec 0c             	sub    $0xc,%esp
80102cb5:	53                   	push   %ebx
80102cb6:	e8 f5 d4 ff ff       	call   801001b0 <bwrite>
  brelse(buf);
80102cbb:	89 1c 24             	mov    %ebx,(%esp)
80102cbe:	e8 2d d5 ff ff       	call   801001f0 <brelse>
}
80102cc3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102cc6:	83 c4 10             	add    $0x10,%esp
80102cc9:	c9                   	leave  
80102cca:	c3                   	ret    
80102ccb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80102ccf:	90                   	nop

80102cd0 <initlog>:
{
80102cd0:	55                   	push   %ebp
80102cd1:	89 e5                	mov    %esp,%ebp
80102cd3:	53                   	push   %ebx
80102cd4:	83 ec 2c             	sub    $0x2c,%esp
80102cd7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102cda:	68 40 80 10 80       	push   $0x80108040
80102cdf:	68 a0 26 11 80       	push   $0x801126a0
80102ce4:	e8 b7 1c 00 00       	call   801049a0 <initlock>
  readsb(dev, &sb);
80102ce9:	58                   	pop    %eax
80102cea:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102ced:	5a                   	pop    %edx
80102cee:	50                   	push   %eax
80102cef:	53                   	push   %ebx
80102cf0:	e8 3b e8 ff ff       	call   80101530 <readsb>
  log.start = sb.logstart;
80102cf5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  struct buf *buf = bread(log.dev, log.start);
80102cf8:	59                   	pop    %ecx
  log.dev = dev;
80102cf9:	89 1d e4 26 11 80    	mov    %ebx,0x801126e4
  log.size = sb.nlog;
80102cff:	8b 55 e8             	mov    -0x18(%ebp),%edx
  log.start = sb.logstart;
80102d02:	a3 d4 26 11 80       	mov    %eax,0x801126d4
  log.size = sb.nlog;
80102d07:	89 15 d8 26 11 80    	mov    %edx,0x801126d8
  struct buf *buf = bread(log.dev, log.start);
80102d0d:	5a                   	pop    %edx
80102d0e:	50                   	push   %eax
80102d0f:	53                   	push   %ebx
80102d10:	e8 bb d3 ff ff       	call   801000d0 <bread>
  for (i = 0; i < log.lh.n; i++) {
80102d15:	83 c4 10             	add    $0x10,%esp
  log.lh.n = lh->n;
80102d18:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102d1b:	89 1d e8 26 11 80    	mov    %ebx,0x801126e8
  for (i = 0; i < log.lh.n; i++) {
80102d21:	85 db                	test   %ebx,%ebx
80102d23:	7e 1d                	jle    80102d42 <initlog+0x72>
80102d25:	31 d2                	xor    %edx,%edx
80102d27:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102d2e:	66 90                	xchg   %ax,%ax
    log.lh.block[i] = lh->block[i];
80102d30:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102d34:	89 0c 95 ec 26 11 80 	mov    %ecx,-0x7feed914(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102d3b:	83 c2 01             	add    $0x1,%edx
80102d3e:	39 d3                	cmp    %edx,%ebx
80102d40:	75 ee                	jne    80102d30 <initlog+0x60>
  brelse(buf);
80102d42:	83 ec 0c             	sub    $0xc,%esp
80102d45:	50                   	push   %eax
80102d46:	e8 a5 d4 ff ff       	call   801001f0 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(); // if committed, copy from log to disk
80102d4b:	e8 80 fe ff ff       	call   80102bd0 <install_trans>
  log.lh.n = 0;
80102d50:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
80102d57:	00 00 00 
  write_head(); // clear the log
80102d5a:	e8 11 ff ff ff       	call   80102c70 <write_head>
}
80102d5f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102d62:	83 c4 10             	add    $0x10,%esp
80102d65:	c9                   	leave  
80102d66:	c3                   	ret    
80102d67:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102d6e:	66 90                	xchg   %ax,%ax

80102d70 <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
80102d70:	55                   	push   %ebp
80102d71:	89 e5                	mov    %esp,%ebp
80102d73:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102d76:	68 a0 26 11 80       	push   $0x801126a0
80102d7b:	e8 f0 1d 00 00       	call   80104b70 <acquire>
80102d80:	83 c4 10             	add    $0x10,%esp
80102d83:	eb 18                	jmp    80102d9d <begin_op+0x2d>
80102d85:	8d 76 00             	lea    0x0(%esi),%esi
  while(1){
    if(log.committing){
      sleep(&log, &log.lock);
80102d88:	83 ec 08             	sub    $0x8,%esp
80102d8b:	68 a0 26 11 80       	push   $0x801126a0
80102d90:	68 a0 26 11 80       	push   $0x801126a0
80102d95:	e8 26 13 00 00       	call   801040c0 <sleep>
80102d9a:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102d9d:	a1 e0 26 11 80       	mov    0x801126e0,%eax
80102da2:	85 c0                	test   %eax,%eax
80102da4:	75 e2                	jne    80102d88 <begin_op+0x18>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102da6:	a1 dc 26 11 80       	mov    0x801126dc,%eax
80102dab:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
80102db1:	83 c0 01             	add    $0x1,%eax
80102db4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102db7:	8d 14 4a             	lea    (%edx,%ecx,2),%edx
80102dba:	83 fa 1e             	cmp    $0x1e,%edx
80102dbd:	7f c9                	jg     80102d88 <begin_op+0x18>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    } else {
      log.outstanding += 1;
      release(&log.lock);
80102dbf:	83 ec 0c             	sub    $0xc,%esp
      log.outstanding += 1;
80102dc2:	a3 dc 26 11 80       	mov    %eax,0x801126dc
      release(&log.lock);
80102dc7:	68 a0 26 11 80       	push   $0x801126a0
80102dcc:	e8 3f 1d 00 00       	call   80104b10 <release>
      break;
    }
  }
}
80102dd1:	83 c4 10             	add    $0x10,%esp
80102dd4:	c9                   	leave  
80102dd5:	c3                   	ret    
80102dd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102ddd:	8d 76 00             	lea    0x0(%esi),%esi

80102de0 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
80102de0:	55                   	push   %ebp
80102de1:	89 e5                	mov    %esp,%ebp
80102de3:	57                   	push   %edi
80102de4:	56                   	push   %esi
80102de5:	53                   	push   %ebx
80102de6:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;

  acquire(&log.lock);
80102de9:	68 a0 26 11 80       	push   $0x801126a0
80102dee:	e8 7d 1d 00 00       	call   80104b70 <acquire>
  log.outstanding -= 1;
80102df3:	a1 dc 26 11 80       	mov    0x801126dc,%eax
  if(log.committing)
80102df8:	8b 35 e0 26 11 80    	mov    0x801126e0,%esi
80102dfe:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
80102e01:	8d 58 ff             	lea    -0x1(%eax),%ebx
80102e04:	89 1d dc 26 11 80    	mov    %ebx,0x801126dc
  if(log.committing)
80102e0a:	85 f6                	test   %esi,%esi
80102e0c:	0f 85 22 01 00 00    	jne    80102f34 <end_op+0x154>
    panic("log.committing");
  if(log.outstanding == 0){
80102e12:	85 db                	test   %ebx,%ebx
80102e14:	0f 85 f6 00 00 00    	jne    80102f10 <end_op+0x130>
    do_commit = 1;
    log.committing = 1;
80102e1a:	c7 05 e0 26 11 80 01 	movl   $0x1,0x801126e0
80102e21:	00 00 00 
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
80102e24:	83 ec 0c             	sub    $0xc,%esp
80102e27:	68 a0 26 11 80       	push   $0x801126a0
80102e2c:	e8 df 1c 00 00       	call   80104b10 <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
80102e31:	8b 0d e8 26 11 80    	mov    0x801126e8,%ecx
80102e37:	83 c4 10             	add    $0x10,%esp
80102e3a:	85 c9                	test   %ecx,%ecx
80102e3c:	7f 42                	jg     80102e80 <end_op+0xa0>
    acquire(&log.lock);
80102e3e:	83 ec 0c             	sub    $0xc,%esp
80102e41:	68 a0 26 11 80       	push   $0x801126a0
80102e46:	e8 25 1d 00 00       	call   80104b70 <acquire>
    wakeup(&log);
80102e4b:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
    log.committing = 0;
80102e52:	c7 05 e0 26 11 80 00 	movl   $0x0,0x801126e0
80102e59:	00 00 00 
    wakeup(&log);
80102e5c:	e8 1f 13 00 00       	call   80104180 <wakeup>
    release(&log.lock);
80102e61:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102e68:	e8 a3 1c 00 00       	call   80104b10 <release>
80102e6d:	83 c4 10             	add    $0x10,%esp
}
80102e70:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e73:	5b                   	pop    %ebx
80102e74:	5e                   	pop    %esi
80102e75:	5f                   	pop    %edi
80102e76:	5d                   	pop    %ebp
80102e77:	c3                   	ret    
80102e78:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102e7f:	90                   	nop
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102e80:	a1 d4 26 11 80       	mov    0x801126d4,%eax
80102e85:	83 ec 08             	sub    $0x8,%esp
80102e88:	01 d8                	add    %ebx,%eax
80102e8a:	83 c0 01             	add    $0x1,%eax
80102e8d:	50                   	push   %eax
80102e8e:	ff 35 e4 26 11 80    	push   0x801126e4
80102e94:	e8 37 d2 ff ff       	call   801000d0 <bread>
80102e99:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102e9b:	58                   	pop    %eax
80102e9c:	5a                   	pop    %edx
80102e9d:	ff 34 9d ec 26 11 80 	push   -0x7feed914(,%ebx,4)
80102ea4:	ff 35 e4 26 11 80    	push   0x801126e4
  for (tail = 0; tail < log.lh.n; tail++) {
80102eaa:	83 c3 01             	add    $0x1,%ebx
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102ead:	e8 1e d2 ff ff       	call   801000d0 <bread>
    memmove(to->data, from->data, BSIZE);
80102eb2:	83 c4 0c             	add    $0xc,%esp
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102eb5:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102eb7:	8d 40 5c             	lea    0x5c(%eax),%eax
80102eba:	68 00 02 00 00       	push   $0x200
80102ebf:	50                   	push   %eax
80102ec0:	8d 46 5c             	lea    0x5c(%esi),%eax
80102ec3:	50                   	push   %eax
80102ec4:	e8 07 1e 00 00       	call   80104cd0 <memmove>
    bwrite(to);  // write the log
80102ec9:	89 34 24             	mov    %esi,(%esp)
80102ecc:	e8 df d2 ff ff       	call   801001b0 <bwrite>
    brelse(from);
80102ed1:	89 3c 24             	mov    %edi,(%esp)
80102ed4:	e8 17 d3 ff ff       	call   801001f0 <brelse>
    brelse(to);
80102ed9:	89 34 24             	mov    %esi,(%esp)
80102edc:	e8 0f d3 ff ff       	call   801001f0 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102ee1:	83 c4 10             	add    $0x10,%esp
80102ee4:	3b 1d e8 26 11 80    	cmp    0x801126e8,%ebx
80102eea:	7c 94                	jl     80102e80 <end_op+0xa0>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
80102eec:	e8 7f fd ff ff       	call   80102c70 <write_head>
    install_trans(); // Now install writes to home locations
80102ef1:	e8 da fc ff ff       	call   80102bd0 <install_trans>
    log.lh.n = 0;
80102ef6:	c7 05 e8 26 11 80 00 	movl   $0x0,0x801126e8
80102efd:	00 00 00 
    write_head();    // Erase the transaction from the log
80102f00:	e8 6b fd ff ff       	call   80102c70 <write_head>
80102f05:	e9 34 ff ff ff       	jmp    80102e3e <end_op+0x5e>
80102f0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&log);
80102f10:	83 ec 0c             	sub    $0xc,%esp
80102f13:	68 a0 26 11 80       	push   $0x801126a0
80102f18:	e8 63 12 00 00       	call   80104180 <wakeup>
  release(&log.lock);
80102f1d:	c7 04 24 a0 26 11 80 	movl   $0x801126a0,(%esp)
80102f24:	e8 e7 1b 00 00       	call   80104b10 <release>
80102f29:	83 c4 10             	add    $0x10,%esp
}
80102f2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f2f:	5b                   	pop    %ebx
80102f30:	5e                   	pop    %esi
80102f31:	5f                   	pop    %edi
80102f32:	5d                   	pop    %ebp
80102f33:	c3                   	ret    
    panic("log.committing");
80102f34:	83 ec 0c             	sub    $0xc,%esp
80102f37:	68 44 80 10 80       	push   $0x80108044
80102f3c:	e8 3f d4 ff ff       	call   80100380 <panic>
80102f41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f48:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80102f4f:	90                   	nop

80102f50 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102f50:	55                   	push   %ebp
80102f51:	89 e5                	mov    %esp,%ebp
80102f53:	53                   	push   %ebx
80102f54:	83 ec 04             	sub    $0x4,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102f57:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
{
80102f5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102f60:	83 fa 1d             	cmp    $0x1d,%edx
80102f63:	0f 8f 85 00 00 00    	jg     80102fee <log_write+0x9e>
80102f69:	a1 d8 26 11 80       	mov    0x801126d8,%eax
80102f6e:	83 e8 01             	sub    $0x1,%eax
80102f71:	39 c2                	cmp    %eax,%edx
80102f73:	7d 79                	jge    80102fee <log_write+0x9e>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102f75:	a1 dc 26 11 80       	mov    0x801126dc,%eax
80102f7a:	85 c0                	test   %eax,%eax
80102f7c:	7e 7d                	jle    80102ffb <log_write+0xab>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102f7e:	83 ec 0c             	sub    $0xc,%esp
80102f81:	68 a0 26 11 80       	push   $0x801126a0
80102f86:	e8 e5 1b 00 00       	call   80104b70 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102f8b:	8b 15 e8 26 11 80    	mov    0x801126e8,%edx
80102f91:	83 c4 10             	add    $0x10,%esp
80102f94:	85 d2                	test   %edx,%edx
80102f96:	7e 4a                	jle    80102fe2 <log_write+0x92>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102f98:	8b 4b 08             	mov    0x8(%ebx),%ecx
  for (i = 0; i < log.lh.n; i++) {
80102f9b:	31 c0                	xor    %eax,%eax
80102f9d:	eb 08                	jmp    80102fa7 <log_write+0x57>
80102f9f:	90                   	nop
80102fa0:	83 c0 01             	add    $0x1,%eax
80102fa3:	39 c2                	cmp    %eax,%edx
80102fa5:	74 29                	je     80102fd0 <log_write+0x80>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102fa7:	39 0c 85 ec 26 11 80 	cmp    %ecx,-0x7feed914(,%eax,4)
80102fae:	75 f0                	jne    80102fa0 <log_write+0x50>
      break;
  }
  log.lh.block[i] = b->blockno;
80102fb0:	89 0c 85 ec 26 11 80 	mov    %ecx,-0x7feed914(,%eax,4)
  if (i == log.lh.n)
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102fb7:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
}
80102fba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  release(&log.lock);
80102fbd:	c7 45 08 a0 26 11 80 	movl   $0x801126a0,0x8(%ebp)
}
80102fc4:	c9                   	leave  
  release(&log.lock);
80102fc5:	e9 46 1b 00 00       	jmp    80104b10 <release>
80102fca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  log.lh.block[i] = b->blockno;
80102fd0:	89 0c 95 ec 26 11 80 	mov    %ecx,-0x7feed914(,%edx,4)
    log.lh.n++;
80102fd7:	83 c2 01             	add    $0x1,%edx
80102fda:	89 15 e8 26 11 80    	mov    %edx,0x801126e8
80102fe0:	eb d5                	jmp    80102fb7 <log_write+0x67>
  log.lh.block[i] = b->blockno;
80102fe2:	8b 43 08             	mov    0x8(%ebx),%eax
80102fe5:	a3 ec 26 11 80       	mov    %eax,0x801126ec
  if (i == log.lh.n)
80102fea:	75 cb                	jne    80102fb7 <log_write+0x67>
80102fec:	eb e9                	jmp    80102fd7 <log_write+0x87>
    panic("too big a transaction");
80102fee:	83 ec 0c             	sub    $0xc,%esp
80102ff1:	68 53 80 10 80       	push   $0x80108053
80102ff6:	e8 85 d3 ff ff       	call   80100380 <panic>
    panic("log_write outside of trans");
80102ffb:	83 ec 0c             	sub    $0xc,%esp
80102ffe:	68 69 80 10 80       	push   $0x80108069
80103003:	e8 78 d3 ff ff       	call   80100380 <panic>
80103008:	66 90                	xchg   %ax,%ax
8010300a:	66 90                	xchg   %ax,%ax
8010300c:	66 90                	xchg   %ax,%ax
8010300e:	66 90                	xchg   %ax,%ax

80103010 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103010:	55                   	push   %ebp
80103011:	89 e5                	mov    %esp,%ebp
80103013:	53                   	push   %ebx
80103014:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80103017:	e8 74 09 00 00       	call   80103990 <cpuid>
8010301c:	89 c3                	mov    %eax,%ebx
8010301e:	e8 6d 09 00 00       	call   80103990 <cpuid>
80103023:	83 ec 04             	sub    $0x4,%esp
80103026:	53                   	push   %ebx
80103027:	50                   	push   %eax
80103028:	68 84 80 10 80       	push   $0x80108084
8010302d:	e8 6e d6 ff ff       	call   801006a0 <cprintf>
  idtinit();       // load idt register
80103032:	e8 09 30 00 00       	call   80106040 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80103037:	e8 f4 08 00 00       	call   80103930 <mycpu>
8010303c:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
8010303e:	b8 01 00 00 00       	mov    $0x1,%eax
80103043:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
8010304a:	e8 61 0c 00 00       	call   80103cb0 <scheduler>
8010304f:	90                   	nop

80103050 <mpenter>:
{
80103050:	55                   	push   %ebp
80103051:	89 e5                	mov    %esp,%ebp
80103053:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80103056:	e8 85 43 00 00       	call   801073e0 <switchkvm>
  seginit();
8010305b:	e8 70 41 00 00       	call   801071d0 <seginit>
  lapicinit();
80103060:	e8 9b f7 ff ff       	call   80102800 <lapicinit>
  mpmain();
80103065:	e8 a6 ff ff ff       	call   80103010 <mpmain>
8010306a:	66 90                	xchg   %ax,%ax
8010306c:	66 90                	xchg   %ax,%ax
8010306e:	66 90                	xchg   %ax,%ax

80103070 <main>:
{
80103070:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103074:	83 e4 f0             	and    $0xfffffff0,%esp
80103077:	ff 71 fc             	push   -0x4(%ecx)
8010307a:	55                   	push   %ebp
8010307b:	89 e5                	mov    %esp,%ebp
8010307d:	53                   	push   %ebx
8010307e:	51                   	push   %ecx
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
8010307f:	83 ec 08             	sub    $0x8,%esp
80103082:	68 00 00 40 80       	push   $0x80400000
80103087:	68 f0 b5 51 80       	push   $0x8051b5f0
8010308c:	e8 8f f5 ff ff       	call   80102620 <kinit1>
  kvmalloc();      // kernel page table
80103091:	e8 4a 48 00 00       	call   801078e0 <kvmalloc>
  mpinit();        // detect other processors
80103096:	e8 85 01 00 00       	call   80103220 <mpinit>
  lapicinit();     // interrupt controller
8010309b:	e8 60 f7 ff ff       	call   80102800 <lapicinit>
  seginit();       // segment descriptors
801030a0:	e8 2b 41 00 00       	call   801071d0 <seginit>
  picinit();       // disable pic
801030a5:	e8 76 03 00 00       	call   80103420 <picinit>
  ioapicinit();    // another interrupt controller
801030aa:	e8 31 f3 ff ff       	call   801023e0 <ioapicinit>
  consoleinit();   // console hardware
801030af:	e8 ac d9 ff ff       	call   80100a60 <consoleinit>
  uartinit();      // serial port
801030b4:	e8 97 34 00 00       	call   80106550 <uartinit>
  pinit();         // process table
801030b9:	e8 52 08 00 00       	call   80103910 <pinit>
  tvinit();        // trap vectors
801030be:	e8 fd 2e 00 00       	call   80105fc0 <tvinit>
  binit();         // buffer cache
801030c3:	e8 78 cf ff ff       	call   80100040 <binit>
  fileinit();      // file table
801030c8:	e8 53 dd ff ff       	call   80100e20 <fileinit>
  ideinit();       // disk 
801030cd:	e8 fe f0 ff ff       	call   801021d0 <ideinit>

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801030d2:	83 c4 0c             	add    $0xc,%esp
801030d5:	68 8a 00 00 00       	push   $0x8a
801030da:	68 8c b4 10 80       	push   $0x8010b48c
801030df:	68 00 70 00 80       	push   $0x80007000
801030e4:	e8 e7 1b 00 00       	call   80104cd0 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801030e9:	83 c4 10             	add    $0x10,%esp
801030ec:	69 05 84 27 11 80 b0 	imul   $0xb0,0x80112784,%eax
801030f3:	00 00 00 
801030f6:	05 a0 27 11 80       	add    $0x801127a0,%eax
801030fb:	3d a0 27 11 80       	cmp    $0x801127a0,%eax
80103100:	76 7e                	jbe    80103180 <main+0x110>
80103102:	bb a0 27 11 80       	mov    $0x801127a0,%ebx
80103107:	eb 20                	jmp    80103129 <main+0xb9>
80103109:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103110:	69 05 84 27 11 80 b0 	imul   $0xb0,0x80112784,%eax
80103117:	00 00 00 
8010311a:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80103120:	05 a0 27 11 80       	add    $0x801127a0,%eax
80103125:	39 c3                	cmp    %eax,%ebx
80103127:	73 57                	jae    80103180 <main+0x110>
    if(c == mycpu())  // We've started already.
80103129:	e8 02 08 00 00       	call   80103930 <mycpu>
8010312e:	39 c3                	cmp    %eax,%ebx
80103130:	74 de                	je     80103110 <main+0xa0>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80103132:	e8 59 f5 ff ff       	call   80102690 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
    *(void(**)(void))(code-8) = mpenter;
    *(int**)(code-12) = (void *) V2P(entrypgdir);

    lapicstartap(c->apicid, V2P(code));
80103137:	83 ec 08             	sub    $0x8,%esp
    *(void(**)(void))(code-8) = mpenter;
8010313a:	c7 05 f8 6f 00 80 50 	movl   $0x80103050,0x80006ff8
80103141:	30 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80103144:	c7 05 f4 6f 00 80 00 	movl   $0x10a000,0x80006ff4
8010314b:	a0 10 00 
    *(void**)(code-4) = stack + KSTACKSIZE;
8010314e:	05 00 10 00 00       	add    $0x1000,%eax
80103153:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    lapicstartap(c->apicid, V2P(code));
80103158:	0f b6 03             	movzbl (%ebx),%eax
8010315b:	68 00 70 00 00       	push   $0x7000
80103160:	50                   	push   %eax
80103161:	e8 ea f7 ff ff       	call   80102950 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103166:	83 c4 10             	add    $0x10,%esp
80103169:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103170:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80103176:	85 c0                	test   %eax,%eax
80103178:	74 f6                	je     80103170 <main+0x100>
8010317a:	eb 94                	jmp    80103110 <main+0xa0>
8010317c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80103180:	83 ec 08             	sub    $0x8,%esp
80103183:	68 00 00 00 8e       	push   $0x8e000000
80103188:	68 00 00 40 80       	push   $0x80400000
8010318d:	e8 2e f4 ff ff       	call   801025c0 <kinit2>
  userinit();      // first user process
80103192:	e8 49 08 00 00       	call   801039e0 <userinit>
  mpmain();        // finish this processor's setup
80103197:	e8 74 fe ff ff       	call   80103010 <mpmain>
8010319c:	66 90                	xchg   %ax,%ax
8010319e:	66 90                	xchg   %ax,%ax

801031a0 <mpsearch1>:
}

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
801031a0:	55                   	push   %ebp
801031a1:	89 e5                	mov    %esp,%ebp
801031a3:	57                   	push   %edi
801031a4:	56                   	push   %esi
  uchar *e, *p, *addr;

  addr = P2V(a);
801031a5:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
{
801031ab:	53                   	push   %ebx
  e = addr+len;
801031ac:	8d 1c 16             	lea    (%esi,%edx,1),%ebx
{
801031af:	83 ec 0c             	sub    $0xc,%esp
  for(p = addr; p < e; p += sizeof(struct mp))
801031b2:	39 de                	cmp    %ebx,%esi
801031b4:	72 10                	jb     801031c6 <mpsearch1+0x26>
801031b6:	eb 50                	jmp    80103208 <mpsearch1+0x68>
801031b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801031bf:	90                   	nop
801031c0:	89 fe                	mov    %edi,%esi
801031c2:	39 fb                	cmp    %edi,%ebx
801031c4:	76 42                	jbe    80103208 <mpsearch1+0x68>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801031c6:	83 ec 04             	sub    $0x4,%esp
801031c9:	8d 7e 10             	lea    0x10(%esi),%edi
801031cc:	6a 04                	push   $0x4
801031ce:	68 98 80 10 80       	push   $0x80108098
801031d3:	56                   	push   %esi
801031d4:	e8 a7 1a 00 00       	call   80104c80 <memcmp>
801031d9:	83 c4 10             	add    $0x10,%esp
801031dc:	85 c0                	test   %eax,%eax
801031de:	75 e0                	jne    801031c0 <mpsearch1+0x20>
801031e0:	89 f2                	mov    %esi,%edx
801031e2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    sum += addr[i];
801031e8:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801031eb:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801031ee:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801031f0:	39 fa                	cmp    %edi,%edx
801031f2:	75 f4                	jne    801031e8 <mpsearch1+0x48>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801031f4:	84 c0                	test   %al,%al
801031f6:	75 c8                	jne    801031c0 <mpsearch1+0x20>
      return (struct mp*)p;
  return 0;
}
801031f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031fb:	89 f0                	mov    %esi,%eax
801031fd:	5b                   	pop    %ebx
801031fe:	5e                   	pop    %esi
801031ff:	5f                   	pop    %edi
80103200:	5d                   	pop    %ebp
80103201:	c3                   	ret    
80103202:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80103208:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010320b:	31 f6                	xor    %esi,%esi
}
8010320d:	5b                   	pop    %ebx
8010320e:	89 f0                	mov    %esi,%eax
80103210:	5e                   	pop    %esi
80103211:	5f                   	pop    %edi
80103212:	5d                   	pop    %ebp
80103213:	c3                   	ret    
80103214:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010321b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010321f:	90                   	nop

80103220 <mpinit>:
  return conf;
}

void
mpinit(void)
{
80103220:	55                   	push   %ebp
80103221:	89 e5                	mov    %esp,%ebp
80103223:	57                   	push   %edi
80103224:	56                   	push   %esi
80103225:	53                   	push   %ebx
80103226:	83 ec 1c             	sub    $0x1c,%esp
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103229:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80103230:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80103237:	c1 e0 08             	shl    $0x8,%eax
8010323a:	09 d0                	or     %edx,%eax
8010323c:	c1 e0 04             	shl    $0x4,%eax
8010323f:	75 1b                	jne    8010325c <mpinit+0x3c>
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103241:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80103248:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
8010324f:	c1 e0 08             	shl    $0x8,%eax
80103252:	09 d0                	or     %edx,%eax
80103254:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80103257:	2d 00 04 00 00       	sub    $0x400,%eax
    if((mp = mpsearch1(p, 1024)))
8010325c:	ba 00 04 00 00       	mov    $0x400,%edx
80103261:	e8 3a ff ff ff       	call   801031a0 <mpsearch1>
80103266:	89 c3                	mov    %eax,%ebx
80103268:	85 c0                	test   %eax,%eax
8010326a:	0f 84 40 01 00 00    	je     801033b0 <mpinit+0x190>
  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103270:	8b 73 04             	mov    0x4(%ebx),%esi
80103273:	85 f6                	test   %esi,%esi
80103275:	0f 84 25 01 00 00    	je     801033a0 <mpinit+0x180>
  if(memcmp(conf, "PCMP", 4) != 0)
8010327b:	83 ec 04             	sub    $0x4,%esp
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010327e:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
  if(memcmp(conf, "PCMP", 4) != 0)
80103284:	6a 04                	push   $0x4
80103286:	68 9d 80 10 80       	push   $0x8010809d
8010328b:	50                   	push   %eax
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
8010328c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
8010328f:	e8 ec 19 00 00       	call   80104c80 <memcmp>
80103294:	83 c4 10             	add    $0x10,%esp
80103297:	85 c0                	test   %eax,%eax
80103299:	0f 85 01 01 00 00    	jne    801033a0 <mpinit+0x180>
  if(conf->version != 1 && conf->version != 4)
8010329f:	0f b6 86 06 00 00 80 	movzbl -0x7ffffffa(%esi),%eax
801032a6:	3c 01                	cmp    $0x1,%al
801032a8:	74 08                	je     801032b2 <mpinit+0x92>
801032aa:	3c 04                	cmp    $0x4,%al
801032ac:	0f 85 ee 00 00 00    	jne    801033a0 <mpinit+0x180>
  if(sum((uchar*)conf, conf->length) != 0)
801032b2:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
  for(i=0; i<len; i++)
801032b9:	66 85 d2             	test   %dx,%dx
801032bc:	74 22                	je     801032e0 <mpinit+0xc0>
801032be:	8d 3c 32             	lea    (%edx,%esi,1),%edi
801032c1:	89 f0                	mov    %esi,%eax
  sum = 0;
801032c3:	31 d2                	xor    %edx,%edx
801032c5:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801032c8:	0f b6 88 00 00 00 80 	movzbl -0x80000000(%eax),%ecx
  for(i=0; i<len; i++)
801032cf:	83 c0 01             	add    $0x1,%eax
    sum += addr[i];
801032d2:	01 ca                	add    %ecx,%edx
  for(i=0; i<len; i++)
801032d4:	39 c7                	cmp    %eax,%edi
801032d6:	75 f0                	jne    801032c8 <mpinit+0xa8>
  if(sum((uchar*)conf, conf->length) != 0)
801032d8:	84 d2                	test   %dl,%dl
801032da:	0f 85 c0 00 00 00    	jne    801033a0 <mpinit+0x180>
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
801032e0:	8b 86 24 00 00 80    	mov    -0x7fffffdc(%esi),%eax
801032e6:	a3 80 26 11 80       	mov    %eax,0x80112680
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801032eb:	0f b7 96 04 00 00 80 	movzwl -0x7ffffffc(%esi),%edx
801032f2:	8d 86 2c 00 00 80    	lea    -0x7fffffd4(%esi),%eax
  ismp = 1;
801032f8:	be 01 00 00 00       	mov    $0x1,%esi
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
801032fd:	03 55 e4             	add    -0x1c(%ebp),%edx
80103300:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80103303:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103307:	90                   	nop
80103308:	39 d0                	cmp    %edx,%eax
8010330a:	73 15                	jae    80103321 <mpinit+0x101>
    switch(*p){
8010330c:	0f b6 08             	movzbl (%eax),%ecx
8010330f:	80 f9 02             	cmp    $0x2,%cl
80103312:	74 4c                	je     80103360 <mpinit+0x140>
80103314:	77 3a                	ja     80103350 <mpinit+0x130>
80103316:	84 c9                	test   %cl,%cl
80103318:	74 56                	je     80103370 <mpinit+0x150>
      p += sizeof(struct mpioapic);
      continue;
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
8010331a:	83 c0 08             	add    $0x8,%eax
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
8010331d:	39 d0                	cmp    %edx,%eax
8010331f:	72 eb                	jb     8010330c <mpinit+0xec>
    default:
      ismp = 0;
      break;
    }
  }
  if(!ismp)
80103321:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103324:	85 f6                	test   %esi,%esi
80103326:	0f 84 d9 00 00 00    	je     80103405 <mpinit+0x1e5>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
8010332c:	80 7b 0c 00          	cmpb   $0x0,0xc(%ebx)
80103330:	74 15                	je     80103347 <mpinit+0x127>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103332:	b8 70 00 00 00       	mov    $0x70,%eax
80103337:	ba 22 00 00 00       	mov    $0x22,%edx
8010333c:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010333d:	ba 23 00 00 00       	mov    $0x23,%edx
80103342:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103343:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103346:	ee                   	out    %al,(%dx)
  }
}
80103347:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010334a:	5b                   	pop    %ebx
8010334b:	5e                   	pop    %esi
8010334c:	5f                   	pop    %edi
8010334d:	5d                   	pop    %ebp
8010334e:	c3                   	ret    
8010334f:	90                   	nop
    switch(*p){
80103350:	83 e9 03             	sub    $0x3,%ecx
80103353:	80 f9 01             	cmp    $0x1,%cl
80103356:	76 c2                	jbe    8010331a <mpinit+0xfa>
80103358:	31 f6                	xor    %esi,%esi
8010335a:	eb ac                	jmp    80103308 <mpinit+0xe8>
8010335c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      ioapicid = ioapic->apicno;
80103360:	0f b6 48 01          	movzbl 0x1(%eax),%ecx
      p += sizeof(struct mpioapic);
80103364:	83 c0 08             	add    $0x8,%eax
      ioapicid = ioapic->apicno;
80103367:	88 0d 80 27 11 80    	mov    %cl,0x80112780
      continue;
8010336d:	eb 99                	jmp    80103308 <mpinit+0xe8>
8010336f:	90                   	nop
      if(ncpu < NCPU) {
80103370:	8b 0d 84 27 11 80    	mov    0x80112784,%ecx
80103376:	83 f9 07             	cmp    $0x7,%ecx
80103379:	7f 19                	jg     80103394 <mpinit+0x174>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010337b:	69 f9 b0 00 00 00    	imul   $0xb0,%ecx,%edi
80103381:	0f b6 58 01          	movzbl 0x1(%eax),%ebx
        ncpu++;
80103385:	83 c1 01             	add    $0x1,%ecx
80103388:	89 0d 84 27 11 80    	mov    %ecx,0x80112784
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
8010338e:	88 9f a0 27 11 80    	mov    %bl,-0x7feed860(%edi)
      p += sizeof(struct mpproc);
80103394:	83 c0 14             	add    $0x14,%eax
      continue;
80103397:	e9 6c ff ff ff       	jmp    80103308 <mpinit+0xe8>
8010339c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    panic("Expect to run on an SMP");
801033a0:	83 ec 0c             	sub    $0xc,%esp
801033a3:	68 a2 80 10 80       	push   $0x801080a2
801033a8:	e8 d3 cf ff ff       	call   80100380 <panic>
801033ad:	8d 76 00             	lea    0x0(%esi),%esi
{
801033b0:	bb 00 00 0f 80       	mov    $0x800f0000,%ebx
801033b5:	eb 13                	jmp    801033ca <mpinit+0x1aa>
801033b7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033be:	66 90                	xchg   %ax,%ax
  for(p = addr; p < e; p += sizeof(struct mp))
801033c0:	89 f3                	mov    %esi,%ebx
801033c2:	81 fe 00 00 10 80    	cmp    $0x80100000,%esi
801033c8:	74 d6                	je     801033a0 <mpinit+0x180>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801033ca:	83 ec 04             	sub    $0x4,%esp
801033cd:	8d 73 10             	lea    0x10(%ebx),%esi
801033d0:	6a 04                	push   $0x4
801033d2:	68 98 80 10 80       	push   $0x80108098
801033d7:	53                   	push   %ebx
801033d8:	e8 a3 18 00 00       	call   80104c80 <memcmp>
801033dd:	83 c4 10             	add    $0x10,%esp
801033e0:	85 c0                	test   %eax,%eax
801033e2:	75 dc                	jne    801033c0 <mpinit+0x1a0>
801033e4:	89 da                	mov    %ebx,%edx
801033e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801033ed:	8d 76 00             	lea    0x0(%esi),%esi
    sum += addr[i];
801033f0:	0f b6 0a             	movzbl (%edx),%ecx
  for(i=0; i<len; i++)
801033f3:	83 c2 01             	add    $0x1,%edx
    sum += addr[i];
801033f6:	01 c8                	add    %ecx,%eax
  for(i=0; i<len; i++)
801033f8:	39 d6                	cmp    %edx,%esi
801033fa:	75 f4                	jne    801033f0 <mpinit+0x1d0>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
801033fc:	84 c0                	test   %al,%al
801033fe:	75 c0                	jne    801033c0 <mpinit+0x1a0>
80103400:	e9 6b fe ff ff       	jmp    80103270 <mpinit+0x50>
    panic("Didn't find a suitable machine");
80103405:	83 ec 0c             	sub    $0xc,%esp
80103408:	68 bc 80 10 80       	push   $0x801080bc
8010340d:	e8 6e cf ff ff       	call   80100380 <panic>
80103412:	66 90                	xchg   %ax,%ax
80103414:	66 90                	xchg   %ax,%ax
80103416:	66 90                	xchg   %ax,%ax
80103418:	66 90                	xchg   %ax,%ax
8010341a:	66 90                	xchg   %ax,%ax
8010341c:	66 90                	xchg   %ax,%ax
8010341e:	66 90                	xchg   %ax,%ax

80103420 <picinit>:
80103420:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103425:	ba 21 00 00 00       	mov    $0x21,%edx
8010342a:	ee                   	out    %al,(%dx)
8010342b:	ba a1 00 00 00       	mov    $0xa1,%edx
80103430:	ee                   	out    %al,(%dx)
picinit(void)
{
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80103431:	c3                   	ret    
80103432:	66 90                	xchg   %ax,%ax
80103434:	66 90                	xchg   %ax,%ax
80103436:	66 90                	xchg   %ax,%ax
80103438:	66 90                	xchg   %ax,%ax
8010343a:	66 90                	xchg   %ax,%ax
8010343c:	66 90                	xchg   %ax,%ax
8010343e:	66 90                	xchg   %ax,%ax

80103440 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80103440:	55                   	push   %ebp
80103441:	89 e5                	mov    %esp,%ebp
80103443:	57                   	push   %edi
80103444:	56                   	push   %esi
80103445:	53                   	push   %ebx
80103446:	83 ec 0c             	sub    $0xc,%esp
80103449:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010344c:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
8010344f:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103455:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
8010345b:	e8 e0 d9 ff ff       	call   80100e40 <filealloc>
80103460:	89 03                	mov    %eax,(%ebx)
80103462:	85 c0                	test   %eax,%eax
80103464:	0f 84 a8 00 00 00    	je     80103512 <pipealloc+0xd2>
8010346a:	e8 d1 d9 ff ff       	call   80100e40 <filealloc>
8010346f:	89 06                	mov    %eax,(%esi)
80103471:	85 c0                	test   %eax,%eax
80103473:	0f 84 87 00 00 00    	je     80103500 <pipealloc+0xc0>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80103479:	e8 12 f2 ff ff       	call   80102690 <kalloc>
8010347e:	89 c7                	mov    %eax,%edi
80103480:	85 c0                	test   %eax,%eax
80103482:	0f 84 b0 00 00 00    	je     80103538 <pipealloc+0xf8>
    goto bad;
  p->readopen = 1;
80103488:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
8010348f:	00 00 00 
  p->writeopen = 1;
  p->nwrite = 0;
  p->nread = 0;
  initlock(&p->lock, "pipe");
80103492:	83 ec 08             	sub    $0x8,%esp
  p->writeopen = 1;
80103495:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010349c:	00 00 00 
  p->nwrite = 0;
8010349f:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801034a6:	00 00 00 
  p->nread = 0;
801034a9:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801034b0:	00 00 00 
  initlock(&p->lock, "pipe");
801034b3:	68 db 80 10 80       	push   $0x801080db
801034b8:	50                   	push   %eax
801034b9:	e8 e2 14 00 00       	call   801049a0 <initlock>
  (*f0)->type = FD_PIPE;
801034be:	8b 03                	mov    (%ebx),%eax
  (*f0)->pipe = p;
  (*f1)->type = FD_PIPE;
  (*f1)->readable = 0;
  (*f1)->writable = 1;
  (*f1)->pipe = p;
  return 0;
801034c0:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801034c3:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801034c9:	8b 03                	mov    (%ebx),%eax
801034cb:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801034cf:	8b 03                	mov    (%ebx),%eax
801034d1:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801034d5:	8b 03                	mov    (%ebx),%eax
801034d7:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
801034da:	8b 06                	mov    (%esi),%eax
801034dc:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
801034e2:	8b 06                	mov    (%esi),%eax
801034e4:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
801034e8:	8b 06                	mov    (%esi),%eax
801034ea:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
801034ee:	8b 06                	mov    (%esi),%eax
801034f0:	89 78 0c             	mov    %edi,0xc(%eax)
  if(*f0)
    fileclose(*f0);
  if(*f1)
    fileclose(*f1);
  return -1;
}
801034f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801034f6:	31 c0                	xor    %eax,%eax
}
801034f8:	5b                   	pop    %ebx
801034f9:	5e                   	pop    %esi
801034fa:	5f                   	pop    %edi
801034fb:	5d                   	pop    %ebp
801034fc:	c3                   	ret    
801034fd:	8d 76 00             	lea    0x0(%esi),%esi
  if(*f0)
80103500:	8b 03                	mov    (%ebx),%eax
80103502:	85 c0                	test   %eax,%eax
80103504:	74 1e                	je     80103524 <pipealloc+0xe4>
    fileclose(*f0);
80103506:	83 ec 0c             	sub    $0xc,%esp
80103509:	50                   	push   %eax
8010350a:	e8 f1 d9 ff ff       	call   80100f00 <fileclose>
8010350f:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80103512:	8b 06                	mov    (%esi),%eax
80103514:	85 c0                	test   %eax,%eax
80103516:	74 0c                	je     80103524 <pipealloc+0xe4>
    fileclose(*f1);
80103518:	83 ec 0c             	sub    $0xc,%esp
8010351b:	50                   	push   %eax
8010351c:	e8 df d9 ff ff       	call   80100f00 <fileclose>
80103521:	83 c4 10             	add    $0x10,%esp
}
80103524:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
80103527:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010352c:	5b                   	pop    %ebx
8010352d:	5e                   	pop    %esi
8010352e:	5f                   	pop    %edi
8010352f:	5d                   	pop    %ebp
80103530:	c3                   	ret    
80103531:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(*f0)
80103538:	8b 03                	mov    (%ebx),%eax
8010353a:	85 c0                	test   %eax,%eax
8010353c:	75 c8                	jne    80103506 <pipealloc+0xc6>
8010353e:	eb d2                	jmp    80103512 <pipealloc+0xd2>

80103540 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103540:	55                   	push   %ebp
80103541:	89 e5                	mov    %esp,%ebp
80103543:	56                   	push   %esi
80103544:	53                   	push   %ebx
80103545:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103548:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&p->lock);
8010354b:	83 ec 0c             	sub    $0xc,%esp
8010354e:	53                   	push   %ebx
8010354f:	e8 1c 16 00 00       	call   80104b70 <acquire>
  if(writable){
80103554:	83 c4 10             	add    $0x10,%esp
80103557:	85 f6                	test   %esi,%esi
80103559:	74 65                	je     801035c0 <pipeclose+0x80>
    p->writeopen = 0;
    wakeup(&p->nread);
8010355b:	83 ec 0c             	sub    $0xc,%esp
8010355e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
    p->writeopen = 0;
80103564:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010356b:	00 00 00 
    wakeup(&p->nread);
8010356e:	50                   	push   %eax
8010356f:	e8 0c 0c 00 00       	call   80104180 <wakeup>
80103574:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103577:	8b 93 3c 02 00 00    	mov    0x23c(%ebx),%edx
8010357d:	85 d2                	test   %edx,%edx
8010357f:	75 0a                	jne    8010358b <pipeclose+0x4b>
80103581:	8b 83 40 02 00 00    	mov    0x240(%ebx),%eax
80103587:	85 c0                	test   %eax,%eax
80103589:	74 15                	je     801035a0 <pipeclose+0x60>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
8010358b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010358e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103591:	5b                   	pop    %ebx
80103592:	5e                   	pop    %esi
80103593:	5d                   	pop    %ebp
    release(&p->lock);
80103594:	e9 77 15 00 00       	jmp    80104b10 <release>
80103599:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    release(&p->lock);
801035a0:	83 ec 0c             	sub    $0xc,%esp
801035a3:	53                   	push   %ebx
801035a4:	e8 67 15 00 00       	call   80104b10 <release>
    kfree((char*)p);
801035a9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801035ac:	83 c4 10             	add    $0x10,%esp
}
801035af:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035b2:	5b                   	pop    %ebx
801035b3:	5e                   	pop    %esi
801035b4:	5d                   	pop    %ebp
    kfree((char*)p);
801035b5:	e9 16 ef ff ff       	jmp    801024d0 <kfree>
801035ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    wakeup(&p->nwrite);
801035c0:	83 ec 0c             	sub    $0xc,%esp
801035c3:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
    p->readopen = 0;
801035c9:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801035d0:	00 00 00 
    wakeup(&p->nwrite);
801035d3:	50                   	push   %eax
801035d4:	e8 a7 0b 00 00       	call   80104180 <wakeup>
801035d9:	83 c4 10             	add    $0x10,%esp
801035dc:	eb 99                	jmp    80103577 <pipeclose+0x37>
801035de:	66 90                	xchg   %ax,%ax

801035e0 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
801035e0:	55                   	push   %ebp
801035e1:	89 e5                	mov    %esp,%ebp
801035e3:	57                   	push   %edi
801035e4:	56                   	push   %esi
801035e5:	53                   	push   %ebx
801035e6:	83 ec 28             	sub    $0x28,%esp
801035e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801035ec:	53                   	push   %ebx
801035ed:	e8 7e 15 00 00       	call   80104b70 <acquire>
  for(i = 0; i < n; i++){
801035f2:	8b 45 10             	mov    0x10(%ebp),%eax
801035f5:	83 c4 10             	add    $0x10,%esp
801035f8:	85 c0                	test   %eax,%eax
801035fa:	0f 8e c0 00 00 00    	jle    801036c0 <pipewrite+0xe0>
80103600:	8b 45 0c             	mov    0xc(%ebp),%eax
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103603:	8b 8b 38 02 00 00    	mov    0x238(%ebx),%ecx
      if(p->readopen == 0 || myproc()->killed){
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103609:	8d bb 34 02 00 00    	lea    0x234(%ebx),%edi
8010360f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103612:	03 45 10             	add    0x10(%ebp),%eax
80103615:	89 45 e0             	mov    %eax,-0x20(%ebp)
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103618:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010361e:	8d b3 38 02 00 00    	lea    0x238(%ebx),%esi
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103624:	89 ca                	mov    %ecx,%edx
80103626:	05 00 02 00 00       	add    $0x200,%eax
8010362b:	39 c1                	cmp    %eax,%ecx
8010362d:	74 3f                	je     8010366e <pipewrite+0x8e>
8010362f:	eb 67                	jmp    80103698 <pipewrite+0xb8>
80103631:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      if(p->readopen == 0 || myproc()->killed){
80103638:	e8 73 03 00 00       	call   801039b0 <myproc>
8010363d:	8b 48 24             	mov    0x24(%eax),%ecx
80103640:	85 c9                	test   %ecx,%ecx
80103642:	75 34                	jne    80103678 <pipewrite+0x98>
      wakeup(&p->nread);
80103644:	83 ec 0c             	sub    $0xc,%esp
80103647:	57                   	push   %edi
80103648:	e8 33 0b 00 00       	call   80104180 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010364d:	58                   	pop    %eax
8010364e:	5a                   	pop    %edx
8010364f:	53                   	push   %ebx
80103650:	56                   	push   %esi
80103651:	e8 6a 0a 00 00       	call   801040c0 <sleep>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103656:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010365c:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103662:	83 c4 10             	add    $0x10,%esp
80103665:	05 00 02 00 00       	add    $0x200,%eax
8010366a:	39 c2                	cmp    %eax,%edx
8010366c:	75 2a                	jne    80103698 <pipewrite+0xb8>
      if(p->readopen == 0 || myproc()->killed){
8010366e:	8b 83 3c 02 00 00    	mov    0x23c(%ebx),%eax
80103674:	85 c0                	test   %eax,%eax
80103676:	75 c0                	jne    80103638 <pipewrite+0x58>
        release(&p->lock);
80103678:	83 ec 0c             	sub    $0xc,%esp
8010367b:	53                   	push   %ebx
8010367c:	e8 8f 14 00 00       	call   80104b10 <release>
        return -1;
80103681:	83 c4 10             	add    $0x10,%esp
80103684:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80103689:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010368c:	5b                   	pop    %ebx
8010368d:	5e                   	pop    %esi
8010368e:	5f                   	pop    %edi
8010368f:	5d                   	pop    %ebp
80103690:	c3                   	ret    
80103691:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103698:	8b 75 e4             	mov    -0x1c(%ebp),%esi
8010369b:	8d 4a 01             	lea    0x1(%edx),%ecx
8010369e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801036a4:	89 8b 38 02 00 00    	mov    %ecx,0x238(%ebx)
801036aa:	0f b6 06             	movzbl (%esi),%eax
  for(i = 0; i < n; i++){
801036ad:	83 c6 01             	add    $0x1,%esi
801036b0:	89 75 e4             	mov    %esi,-0x1c(%ebp)
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801036b3:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801036b7:	3b 75 e0             	cmp    -0x20(%ebp),%esi
801036ba:	0f 85 58 ff ff ff    	jne    80103618 <pipewrite+0x38>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801036c0:	83 ec 0c             	sub    $0xc,%esp
801036c3:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801036c9:	50                   	push   %eax
801036ca:	e8 b1 0a 00 00       	call   80104180 <wakeup>
  release(&p->lock);
801036cf:	89 1c 24             	mov    %ebx,(%esp)
801036d2:	e8 39 14 00 00       	call   80104b10 <release>
  return n;
801036d7:	8b 45 10             	mov    0x10(%ebp),%eax
801036da:	83 c4 10             	add    $0x10,%esp
801036dd:	eb aa                	jmp    80103689 <pipewrite+0xa9>
801036df:	90                   	nop

801036e0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801036e0:	55                   	push   %ebp
801036e1:	89 e5                	mov    %esp,%ebp
801036e3:	57                   	push   %edi
801036e4:	56                   	push   %esi
801036e5:	53                   	push   %ebx
801036e6:	83 ec 18             	sub    $0x18,%esp
801036e9:	8b 75 08             	mov    0x8(%ebp),%esi
801036ec:	8b 7d 0c             	mov    0xc(%ebp),%edi
  int i;

  acquire(&p->lock);
801036ef:	56                   	push   %esi
801036f0:	8d 9e 34 02 00 00    	lea    0x234(%esi),%ebx
801036f6:	e8 75 14 00 00       	call   80104b70 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801036fb:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103701:	83 c4 10             	add    $0x10,%esp
80103704:	39 86 38 02 00 00    	cmp    %eax,0x238(%esi)
8010370a:	74 2f                	je     8010373b <piperead+0x5b>
8010370c:	eb 37                	jmp    80103745 <piperead+0x65>
8010370e:	66 90                	xchg   %ax,%ax
    if(myproc()->killed){
80103710:	e8 9b 02 00 00       	call   801039b0 <myproc>
80103715:	8b 48 24             	mov    0x24(%eax),%ecx
80103718:	85 c9                	test   %ecx,%ecx
8010371a:	0f 85 80 00 00 00    	jne    801037a0 <piperead+0xc0>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103720:	83 ec 08             	sub    $0x8,%esp
80103723:	56                   	push   %esi
80103724:	53                   	push   %ebx
80103725:	e8 96 09 00 00       	call   801040c0 <sleep>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
8010372a:	8b 86 38 02 00 00    	mov    0x238(%esi),%eax
80103730:	83 c4 10             	add    $0x10,%esp
80103733:	39 86 34 02 00 00    	cmp    %eax,0x234(%esi)
80103739:	75 0a                	jne    80103745 <piperead+0x65>
8010373b:	8b 86 40 02 00 00    	mov    0x240(%esi),%eax
80103741:	85 c0                	test   %eax,%eax
80103743:	75 cb                	jne    80103710 <piperead+0x30>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103745:	8b 55 10             	mov    0x10(%ebp),%edx
80103748:	31 db                	xor    %ebx,%ebx
8010374a:	85 d2                	test   %edx,%edx
8010374c:	7f 20                	jg     8010376e <piperead+0x8e>
8010374e:	eb 2c                	jmp    8010377c <piperead+0x9c>
    if(p->nread == p->nwrite)
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103750:	8d 48 01             	lea    0x1(%eax),%ecx
80103753:	25 ff 01 00 00       	and    $0x1ff,%eax
80103758:	89 8e 34 02 00 00    	mov    %ecx,0x234(%esi)
8010375e:	0f b6 44 06 34       	movzbl 0x34(%esi,%eax,1),%eax
80103763:	88 04 1f             	mov    %al,(%edi,%ebx,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103766:	83 c3 01             	add    $0x1,%ebx
80103769:	39 5d 10             	cmp    %ebx,0x10(%ebp)
8010376c:	74 0e                	je     8010377c <piperead+0x9c>
    if(p->nread == p->nwrite)
8010376e:	8b 86 34 02 00 00    	mov    0x234(%esi),%eax
80103774:	3b 86 38 02 00 00    	cmp    0x238(%esi),%eax
8010377a:	75 d4                	jne    80103750 <piperead+0x70>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010377c:	83 ec 0c             	sub    $0xc,%esp
8010377f:	8d 86 38 02 00 00    	lea    0x238(%esi),%eax
80103785:	50                   	push   %eax
80103786:	e8 f5 09 00 00       	call   80104180 <wakeup>
  release(&p->lock);
8010378b:	89 34 24             	mov    %esi,(%esp)
8010378e:	e8 7d 13 00 00       	call   80104b10 <release>
  return i;
80103793:	83 c4 10             	add    $0x10,%esp
}
80103796:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103799:	89 d8                	mov    %ebx,%eax
8010379b:	5b                   	pop    %ebx
8010379c:	5e                   	pop    %esi
8010379d:	5f                   	pop    %edi
8010379e:	5d                   	pop    %ebp
8010379f:	c3                   	ret    
      release(&p->lock);
801037a0:	83 ec 0c             	sub    $0xc,%esp
      return -1;
801037a3:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
      release(&p->lock);
801037a8:	56                   	push   %esi
801037a9:	e8 62 13 00 00       	call   80104b10 <release>
      return -1;
801037ae:	83 c4 10             	add    $0x10,%esp
}
801037b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801037b4:	89 d8                	mov    %ebx,%eax
801037b6:	5b                   	pop    %ebx
801037b7:	5e                   	pop    %esi
801037b8:	5f                   	pop    %edi
801037b9:	5d                   	pop    %ebp
801037ba:	c3                   	ret    
801037bb:	66 90                	xchg   %ax,%ax
801037bd:	66 90                	xchg   %ax,%ax
801037bf:	90                   	nop

801037c0 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
801037c0:	55                   	push   %ebp
801037c1:	89 e5                	mov    %esp,%ebp
801037c3:	53                   	push   %ebx
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801037c4:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
{
801037c9:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801037cc:	68 20 2d 11 80       	push   $0x80112d20
801037d1:	e8 9a 13 00 00       	call   80104b70 <acquire>
801037d6:	83 c4 10             	add    $0x10,%esp
801037d9:	eb 17                	jmp    801037f2 <allocproc+0x32>
801037db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801037df:	90                   	nop
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801037e0:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
801037e6:	81 fb 54 9d 11 80    	cmp    $0x80119d54,%ebx
801037ec:	0f 84 96 00 00 00    	je     80103888 <allocproc+0xc8>
    if(p->state == UNUSED)
801037f2:	8b 43 0c             	mov    0xc(%ebx),%eax
801037f5:	85 c0                	test   %eax,%eax
801037f7:	75 e7                	jne    801037e0 <allocproc+0x20>
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;
801037f9:	a1 04 b0 10 80       	mov    0x8010b004,%eax

  ////////////////////////////////////////////////////////
  // Initialize wmap regions struct and wmap_count to 0 //
  ////////////////////////////////////////////////////////
  p->wmap_count = 0;
  memset(p->wmap_regions, 0, sizeof(p->wmap_regions));
801037fe:	83 ec 04             	sub    $0x4,%esp
  p->state = EMBRYO;
80103801:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->wmap_count = 0;
80103808:	c7 83 bc 01 00 00 00 	movl   $0x0,0x1bc(%ebx)
8010380f:	00 00 00 
  p->pid = nextpid++;
80103812:	89 43 10             	mov    %eax,0x10(%ebx)
80103815:	8d 50 01             	lea    0x1(%eax),%edx
  memset(p->wmap_regions, 0, sizeof(p->wmap_regions));
80103818:	8d 43 7c             	lea    0x7c(%ebx),%eax
8010381b:	68 40 01 00 00       	push   $0x140
80103820:	6a 00                	push   $0x0
80103822:	50                   	push   %eax
  p->pid = nextpid++;
80103823:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
  memset(p->wmap_regions, 0, sizeof(p->wmap_regions));
80103829:	e8 02 14 00 00       	call   80104c30 <memset>

  release(&ptable.lock);
8010382e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103835:	e8 d6 12 00 00       	call   80104b10 <release>

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
8010383a:	e8 51 ee ff ff       	call   80102690 <kalloc>
8010383f:	83 c4 10             	add    $0x10,%esp
80103842:	89 43 08             	mov    %eax,0x8(%ebx)
80103845:	85 c0                	test   %eax,%eax
80103847:	74 58                	je     801038a1 <allocproc+0xe1>
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80103849:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
8010384f:	83 ec 04             	sub    $0x4,%esp
  sp -= sizeof *p->context;
80103852:	05 9c 0f 00 00       	add    $0xf9c,%eax
  sp -= sizeof *p->tf;
80103857:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010385a:	c7 40 14 af 5f 10 80 	movl   $0x80105faf,0x14(%eax)
  p->context = (struct context*)sp;
80103861:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103864:	6a 14                	push   $0x14
80103866:	6a 00                	push   $0x0
80103868:	50                   	push   %eax
80103869:	e8 c2 13 00 00       	call   80104c30 <memset>
  p->context->eip = (uint)forkret;
8010386e:	8b 43 1c             	mov    0x1c(%ebx),%eax

  return p;
80103871:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80103874:	c7 40 10 c0 38 10 80 	movl   $0x801038c0,0x10(%eax)
}
8010387b:	89 d8                	mov    %ebx,%eax
8010387d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103880:	c9                   	leave  
80103881:	c3                   	ret    
80103882:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  release(&ptable.lock);
80103888:	83 ec 0c             	sub    $0xc,%esp
  return 0;
8010388b:	31 db                	xor    %ebx,%ebx
  release(&ptable.lock);
8010388d:	68 20 2d 11 80       	push   $0x80112d20
80103892:	e8 79 12 00 00       	call   80104b10 <release>
}
80103897:	89 d8                	mov    %ebx,%eax
  return 0;
80103899:	83 c4 10             	add    $0x10,%esp
}
8010389c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010389f:	c9                   	leave  
801038a0:	c3                   	ret    
    p->state = UNUSED;
801038a1:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801038a8:	31 db                	xor    %ebx,%ebx
}
801038aa:	89 d8                	mov    %ebx,%eax
801038ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038af:	c9                   	leave  
801038b0:	c3                   	ret    
801038b1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801038b8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801038bf:	90                   	nop

801038c0 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
801038c0:	55                   	push   %ebp
801038c1:	89 e5                	mov    %esp,%ebp
801038c3:	83 ec 14             	sub    $0x14,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
801038c6:	68 20 2d 11 80       	push   $0x80112d20
801038cb:	e8 40 12 00 00       	call   80104b10 <release>

  if (first) {
801038d0:	a1 00 b0 10 80       	mov    0x8010b000,%eax
801038d5:	83 c4 10             	add    $0x10,%esp
801038d8:	85 c0                	test   %eax,%eax
801038da:	75 04                	jne    801038e0 <forkret+0x20>
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}
801038dc:	c9                   	leave  
801038dd:	c3                   	ret    
801038de:	66 90                	xchg   %ax,%ax
    first = 0;
801038e0:	c7 05 00 b0 10 80 00 	movl   $0x0,0x8010b000
801038e7:	00 00 00 
    iinit(ROOTDEV);
801038ea:	83 ec 0c             	sub    $0xc,%esp
801038ed:	6a 01                	push   $0x1
801038ef:	e8 7c dc ff ff       	call   80101570 <iinit>
    initlog(ROOTDEV);
801038f4:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801038fb:	e8 d0 f3 ff ff       	call   80102cd0 <initlog>
}
80103900:	83 c4 10             	add    $0x10,%esp
80103903:	c9                   	leave  
80103904:	c3                   	ret    
80103905:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010390c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80103910 <pinit>:
{
80103910:	55                   	push   %ebp
80103911:	89 e5                	mov    %esp,%ebp
80103913:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103916:	68 e0 80 10 80       	push   $0x801080e0
8010391b:	68 20 2d 11 80       	push   $0x80112d20
80103920:	e8 7b 10 00 00       	call   801049a0 <initlock>
}
80103925:	83 c4 10             	add    $0x10,%esp
80103928:	c9                   	leave  
80103929:	c3                   	ret    
8010392a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80103930 <mycpu>:
{
80103930:	55                   	push   %ebp
80103931:	89 e5                	mov    %esp,%ebp
80103933:	56                   	push   %esi
80103934:	53                   	push   %ebx
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103935:	9c                   	pushf  
80103936:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103937:	f6 c4 02             	test   $0x2,%ah
8010393a:	75 46                	jne    80103982 <mycpu+0x52>
  apicid = lapicid();
8010393c:	e8 bf ef ff ff       	call   80102900 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103941:	8b 35 84 27 11 80    	mov    0x80112784,%esi
80103947:	85 f6                	test   %esi,%esi
80103949:	7e 2a                	jle    80103975 <mycpu+0x45>
8010394b:	31 d2                	xor    %edx,%edx
8010394d:	eb 08                	jmp    80103957 <mycpu+0x27>
8010394f:	90                   	nop
80103950:	83 c2 01             	add    $0x1,%edx
80103953:	39 f2                	cmp    %esi,%edx
80103955:	74 1e                	je     80103975 <mycpu+0x45>
    if (cpus[i].apicid == apicid)
80103957:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010395d:	0f b6 99 a0 27 11 80 	movzbl -0x7feed860(%ecx),%ebx
80103964:	39 c3                	cmp    %eax,%ebx
80103966:	75 e8                	jne    80103950 <mycpu+0x20>
}
80103968:	8d 65 f8             	lea    -0x8(%ebp),%esp
      return &cpus[i];
8010396b:	8d 81 a0 27 11 80    	lea    -0x7feed860(%ecx),%eax
}
80103971:	5b                   	pop    %ebx
80103972:	5e                   	pop    %esi
80103973:	5d                   	pop    %ebp
80103974:	c3                   	ret    
  panic("unknown apicid\n");
80103975:	83 ec 0c             	sub    $0xc,%esp
80103978:	68 e7 80 10 80       	push   $0x801080e7
8010397d:	e8 fe c9 ff ff       	call   80100380 <panic>
    panic("mycpu called with interrupts enabled\n");
80103982:	83 ec 0c             	sub    $0xc,%esp
80103985:	68 c4 81 10 80       	push   $0x801081c4
8010398a:	e8 f1 c9 ff ff       	call   80100380 <panic>
8010398f:	90                   	nop

80103990 <cpuid>:
cpuid() {
80103990:	55                   	push   %ebp
80103991:	89 e5                	mov    %esp,%ebp
80103993:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103996:	e8 95 ff ff ff       	call   80103930 <mycpu>
}
8010399b:	c9                   	leave  
  return mycpu()-cpus;
8010399c:	2d a0 27 11 80       	sub    $0x801127a0,%eax
801039a1:	c1 f8 04             	sar    $0x4,%eax
801039a4:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801039aa:	c3                   	ret    
801039ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801039af:	90                   	nop

801039b0 <myproc>:
myproc(void) {
801039b0:	55                   	push   %ebp
801039b1:	89 e5                	mov    %esp,%ebp
801039b3:	53                   	push   %ebx
801039b4:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801039b7:	e8 64 10 00 00       	call   80104a20 <pushcli>
  c = mycpu();
801039bc:	e8 6f ff ff ff       	call   80103930 <mycpu>
  p = c->proc;
801039c1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801039c7:	e8 a4 10 00 00       	call   80104a70 <popcli>
}
801039cc:	89 d8                	mov    %ebx,%eax
801039ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039d1:	c9                   	leave  
801039d2:	c3                   	ret    
801039d3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801039da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801039e0 <userinit>:
{
801039e0:	55                   	push   %ebp
801039e1:	89 e5                	mov    %esp,%ebp
801039e3:	53                   	push   %ebx
801039e4:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801039e7:	e8 d4 fd ff ff       	call   801037c0 <allocproc>
801039ec:	89 c3                	mov    %eax,%ebx
  initproc = p;
801039ee:	a3 54 9d 11 80       	mov    %eax,0x80119d54
  if((p->pgdir = setupkvm()) == 0)
801039f3:	e8 68 3e 00 00       	call   80107860 <setupkvm>
801039f8:	89 43 04             	mov    %eax,0x4(%ebx)
801039fb:	85 c0                	test   %eax,%eax
801039fd:	0f 84 bd 00 00 00    	je     80103ac0 <userinit+0xe0>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103a03:	83 ec 04             	sub    $0x4,%esp
80103a06:	68 2c 00 00 00       	push   $0x2c
80103a0b:	68 60 b4 10 80       	push   $0x8010b460
80103a10:	50                   	push   %eax
80103a11:	e8 ea 3a 00 00       	call   80107500 <inituvm>
  memset(p->tf, 0, sizeof(*p->tf));
80103a16:	83 c4 0c             	add    $0xc,%esp
  p->sz = PGSIZE;
80103a19:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103a1f:	6a 4c                	push   $0x4c
80103a21:	6a 00                	push   $0x0
80103a23:	ff 73 18             	push   0x18(%ebx)
80103a26:	e8 05 12 00 00       	call   80104c30 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103a2b:	8b 43 18             	mov    0x18(%ebx),%eax
80103a2e:	ba 1b 00 00 00       	mov    $0x1b,%edx
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a33:	83 c4 0c             	add    $0xc,%esp
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103a36:	b9 23 00 00 00       	mov    $0x23,%ecx
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
80103a3b:	66 89 50 3c          	mov    %dx,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103a3f:	8b 43 18             	mov    0x18(%ebx),%eax
80103a42:	66 89 48 2c          	mov    %cx,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103a46:	8b 43 18             	mov    0x18(%ebx),%eax
80103a49:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a4d:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103a51:	8b 43 18             	mov    0x18(%ebx),%eax
80103a54:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103a58:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103a5c:	8b 43 18             	mov    0x18(%ebx),%eax
80103a5f:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103a66:	8b 43 18             	mov    0x18(%ebx),%eax
80103a69:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103a70:	8b 43 18             	mov    0x18(%ebx),%eax
80103a73:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103a7a:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103a7d:	6a 10                	push   $0x10
80103a7f:	68 10 81 10 80       	push   $0x80108110
80103a84:	50                   	push   %eax
80103a85:	e8 66 13 00 00       	call   80104df0 <safestrcpy>
  p->cwd = namei("/");
80103a8a:	c7 04 24 19 81 10 80 	movl   $0x80108119,(%esp)
80103a91:	e8 1a e6 ff ff       	call   801020b0 <namei>
80103a96:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103a99:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103aa0:	e8 cb 10 00 00       	call   80104b70 <acquire>
  p->state = RUNNABLE;
80103aa5:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103aac:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103ab3:	e8 58 10 00 00       	call   80104b10 <release>
}
80103ab8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103abb:	83 c4 10             	add    $0x10,%esp
80103abe:	c9                   	leave  
80103abf:	c3                   	ret    
    panic("userinit: out of memory?");
80103ac0:	83 ec 0c             	sub    $0xc,%esp
80103ac3:	68 f7 80 10 80       	push   $0x801080f7
80103ac8:	e8 b3 c8 ff ff       	call   80100380 <panic>
80103acd:	8d 76 00             	lea    0x0(%esi),%esi

80103ad0 <growproc>:
{
80103ad0:	55                   	push   %ebp
80103ad1:	89 e5                	mov    %esp,%ebp
80103ad3:	56                   	push   %esi
80103ad4:	53                   	push   %ebx
80103ad5:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
80103ad8:	e8 43 0f 00 00       	call   80104a20 <pushcli>
  c = mycpu();
80103add:	e8 4e fe ff ff       	call   80103930 <mycpu>
  p = c->proc;
80103ae2:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103ae8:	e8 83 0f 00 00       	call   80104a70 <popcli>
  sz = curproc->sz;
80103aed:	8b 03                	mov    (%ebx),%eax
  if(n > 0){
80103aef:	85 f6                	test   %esi,%esi
80103af1:	7f 1d                	jg     80103b10 <growproc+0x40>
  } else if(n < 0){
80103af3:	75 3b                	jne    80103b30 <growproc+0x60>
  switchuvm(curproc);
80103af5:	83 ec 0c             	sub    $0xc,%esp
  curproc->sz = sz;
80103af8:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103afa:	53                   	push   %ebx
80103afb:	e8 f0 38 00 00       	call   801073f0 <switchuvm>
  return 0;
80103b00:	83 c4 10             	add    $0x10,%esp
80103b03:	31 c0                	xor    %eax,%eax
}
80103b05:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b08:	5b                   	pop    %ebx
80103b09:	5e                   	pop    %esi
80103b0a:	5d                   	pop    %ebp
80103b0b:	c3                   	ret    
80103b0c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103b10:	83 ec 04             	sub    $0x4,%esp
80103b13:	01 c6                	add    %eax,%esi
80103b15:	56                   	push   %esi
80103b16:	50                   	push   %eax
80103b17:	ff 73 04             	push   0x4(%ebx)
80103b1a:	e8 61 3b 00 00       	call   80107680 <allocuvm>
80103b1f:	83 c4 10             	add    $0x10,%esp
80103b22:	85 c0                	test   %eax,%eax
80103b24:	75 cf                	jne    80103af5 <growproc+0x25>
      return -1;
80103b26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103b2b:	eb d8                	jmp    80103b05 <growproc+0x35>
80103b2d:	8d 76 00             	lea    0x0(%esi),%esi
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103b30:	83 ec 04             	sub    $0x4,%esp
80103b33:	01 c6                	add    %eax,%esi
80103b35:	56                   	push   %esi
80103b36:	50                   	push   %eax
80103b37:	ff 73 04             	push   0x4(%ebx)
80103b3a:	e8 71 3c 00 00       	call   801077b0 <deallocuvm>
80103b3f:	83 c4 10             	add    $0x10,%esp
80103b42:	85 c0                	test   %eax,%eax
80103b44:	75 af                	jne    80103af5 <growproc+0x25>
80103b46:	eb de                	jmp    80103b26 <growproc+0x56>
80103b48:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103b4f:	90                   	nop

80103b50 <fork>:
{
80103b50:	55                   	push   %ebp
80103b51:	89 e5                	mov    %esp,%ebp
80103b53:	57                   	push   %edi
80103b54:	56                   	push   %esi
80103b55:	53                   	push   %ebx
80103b56:	83 ec 1c             	sub    $0x1c,%esp
  pushcli();
80103b59:	e8 c2 0e 00 00       	call   80104a20 <pushcli>
  c = mycpu();
80103b5e:	e8 cd fd ff ff       	call   80103930 <mycpu>
  p = c->proc;
80103b63:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103b69:	e8 02 0f 00 00       	call   80104a70 <popcli>
  if((np = allocproc()) == 0){
80103b6e:	e8 4d fc ff ff       	call   801037c0 <allocproc>
80103b73:	85 c0                	test   %eax,%eax
80103b75:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103b78:	0f 84 fc 00 00 00    	je     80103c7a <fork+0x12a>
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103b7e:	83 ec 08             	sub    $0x8,%esp
80103b81:	ff 33                	push   (%ebx)
80103b83:	ff 73 04             	push   0x4(%ebx)
80103b86:	e8 c5 3d 00 00       	call   80107950 <copyuvm>
80103b8b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103b8e:	83 c4 10             	add    $0x10,%esp
80103b91:	89 42 04             	mov    %eax,0x4(%edx)
80103b94:	85 c0                	test   %eax,%eax
80103b96:	0f 84 e5 00 00 00    	je     80103c81 <fork+0x131>
  np->sz = curproc->sz;
80103b9c:	8b 03                	mov    (%ebx),%eax
  *np->tf = *curproc->tf;
80103b9e:	8b 7a 18             	mov    0x18(%edx),%edi
  np->parent = curproc;
80103ba1:	89 5a 14             	mov    %ebx,0x14(%edx)
  *np->tf = *curproc->tf;
80103ba4:	b9 13 00 00 00       	mov    $0x13,%ecx
  np->sz = curproc->sz;
80103ba9:	89 02                	mov    %eax,(%edx)
  *np->tf = *curproc->tf;
80103bab:	8b 73 18             	mov    0x18(%ebx),%esi
80103bae:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  for(i = 0; i < NOFILE; i++)
80103bb0:	31 f6                	xor    %esi,%esi
  np->tf->eax = 0;
80103bb2:	8b 42 18             	mov    0x18(%edx),%eax
80103bb5:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103bbc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[i])
80103bc0:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103bc4:	85 c0                	test   %eax,%eax
80103bc6:	74 16                	je     80103bde <fork+0x8e>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103bc8:	83 ec 0c             	sub    $0xc,%esp
80103bcb:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80103bce:	50                   	push   %eax
80103bcf:	e8 dc d2 ff ff       	call   80100eb0 <filedup>
80103bd4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103bd7:	83 c4 10             	add    $0x10,%esp
80103bda:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
  for(i = 0; i < NOFILE; i++)
80103bde:	83 c6 01             	add    $0x1,%esi
80103be1:	83 fe 10             	cmp    $0x10,%esi
80103be4:	75 da                	jne    80103bc0 <fork+0x70>
  np->cwd = idup(curproc->cwd);
80103be6:	83 ec 0c             	sub    $0xc,%esp
80103be9:	ff 73 68             	push   0x68(%ebx)
80103bec:	89 55 e4             	mov    %edx,-0x1c(%ebp)
80103bef:	e8 6c db ff ff       	call   80101760 <idup>
80103bf4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103bf7:	83 c4 0c             	add    $0xc,%esp
  np->cwd = idup(curproc->cwd);
80103bfa:	89 42 68             	mov    %eax,0x68(%edx)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103bfd:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103c00:	6a 10                	push   $0x10
80103c02:	50                   	push   %eax
80103c03:	8d 42 6c             	lea    0x6c(%edx),%eax
80103c06:	50                   	push   %eax
80103c07:	e8 e4 11 00 00       	call   80104df0 <safestrcpy>
  pid = np->pid;
80103c0c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103c0f:	8b 72 10             	mov    0x10(%edx),%esi
  acquire(&ptable.lock);
80103c12:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103c19:	e8 52 0f 00 00       	call   80104b70 <acquire>
  np->state = RUNNABLE;
80103c1e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103c21:	83 c4 10             	add    $0x10,%esp
80103c24:	b8 7c 00 00 00       	mov    $0x7c,%eax
80103c29:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
    np->wmap_regions[i] = curproc->wmap_regions[i];
80103c30:	8b 0c 03             	mov    (%ebx,%eax,1),%ecx
80103c33:	89 0c 02             	mov    %ecx,(%edx,%eax,1)
80103c36:	8b 4c 03 04          	mov    0x4(%ebx,%eax,1),%ecx
80103c3a:	89 4c 02 04          	mov    %ecx,0x4(%edx,%eax,1)
80103c3e:	8b 4c 03 08          	mov    0x8(%ebx,%eax,1),%ecx
80103c42:	89 4c 02 08          	mov    %ecx,0x8(%edx,%eax,1)
80103c46:	8b 4c 03 0c          	mov    0xc(%ebx,%eax,1),%ecx
80103c4a:	89 4c 02 0c          	mov    %ecx,0xc(%edx,%eax,1)
80103c4e:	8b 4c 03 10          	mov    0x10(%ebx,%eax,1),%ecx
80103c52:	89 4c 02 10          	mov    %ecx,0x10(%edx,%eax,1)
  for (int i = 0; i < MAX_NUM_WMAPS; i++){
80103c56:	83 c0 14             	add    $0x14,%eax
80103c59:	3d bc 01 00 00       	cmp    $0x1bc,%eax
80103c5e:	75 d0                	jne    80103c30 <fork+0xe0>
  release(&ptable.lock);
80103c60:	83 ec 0c             	sub    $0xc,%esp
80103c63:	68 20 2d 11 80       	push   $0x80112d20
80103c68:	e8 a3 0e 00 00       	call   80104b10 <release>
  return pid;
80103c6d:	83 c4 10             	add    $0x10,%esp
}
80103c70:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103c73:	89 f0                	mov    %esi,%eax
80103c75:	5b                   	pop    %ebx
80103c76:	5e                   	pop    %esi
80103c77:	5f                   	pop    %edi
80103c78:	5d                   	pop    %ebp
80103c79:	c3                   	ret    
    return -1;
80103c7a:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103c7f:	eb ef                	jmp    80103c70 <fork+0x120>
    kfree(np->kstack);
80103c81:	83 ec 0c             	sub    $0xc,%esp
80103c84:	ff 72 08             	push   0x8(%edx)
    return -1;
80103c87:	be ff ff ff ff       	mov    $0xffffffff,%esi
    kfree(np->kstack);
80103c8c:	e8 3f e8 ff ff       	call   801024d0 <kfree>
    np->kstack = 0;
80103c91:	8b 55 e4             	mov    -0x1c(%ebp),%edx
    return -1;
80103c94:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
80103c97:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
    np->state = UNUSED;
80103c9e:	c7 42 0c 00 00 00 00 	movl   $0x0,0xc(%edx)
    return -1;
80103ca5:	eb c9                	jmp    80103c70 <fork+0x120>
80103ca7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103cae:	66 90                	xchg   %ax,%ax

80103cb0 <scheduler>:
{
80103cb0:	55                   	push   %ebp
80103cb1:	89 e5                	mov    %esp,%ebp
80103cb3:	57                   	push   %edi
80103cb4:	56                   	push   %esi
80103cb5:	53                   	push   %ebx
80103cb6:	83 ec 0c             	sub    $0xc,%esp
  struct cpu *c = mycpu();
80103cb9:	e8 72 fc ff ff       	call   80103930 <mycpu>
  c->proc = 0;
80103cbe:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103cc5:	00 00 00 
  struct cpu *c = mycpu();
80103cc8:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103cca:	8d 78 04             	lea    0x4(%eax),%edi
80103ccd:	8d 76 00             	lea    0x0(%esi),%esi
  asm volatile("sti");
80103cd0:	fb                   	sti    
    acquire(&ptable.lock);
80103cd1:	83 ec 0c             	sub    $0xc,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103cd4:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
    acquire(&ptable.lock);
80103cd9:	68 20 2d 11 80       	push   $0x80112d20
80103cde:	e8 8d 0e 00 00       	call   80104b70 <acquire>
80103ce3:	83 c4 10             	add    $0x10,%esp
80103ce6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ced:	8d 76 00             	lea    0x0(%esi),%esi
      if(p->state != RUNNABLE)
80103cf0:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103cf4:	75 33                	jne    80103d29 <scheduler+0x79>
      switchuvm(p);
80103cf6:	83 ec 0c             	sub    $0xc,%esp
      c->proc = p;
80103cf9:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103cff:	53                   	push   %ebx
80103d00:	e8 eb 36 00 00       	call   801073f0 <switchuvm>
      swtch(&(c->scheduler), p->context);
80103d05:	58                   	pop    %eax
80103d06:	5a                   	pop    %edx
80103d07:	ff 73 1c             	push   0x1c(%ebx)
80103d0a:	57                   	push   %edi
      p->state = RUNNING;
80103d0b:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103d12:	e8 34 11 00 00       	call   80104e4b <swtch>
      switchkvm();
80103d17:	e8 c4 36 00 00       	call   801073e0 <switchkvm>
      c->proc = 0;
80103d1c:	83 c4 10             	add    $0x10,%esp
80103d1f:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103d26:	00 00 00 
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103d29:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
80103d2f:	81 fb 54 9d 11 80    	cmp    $0x80119d54,%ebx
80103d35:	75 b9                	jne    80103cf0 <scheduler+0x40>
    release(&ptable.lock);
80103d37:	83 ec 0c             	sub    $0xc,%esp
80103d3a:	68 20 2d 11 80       	push   $0x80112d20
80103d3f:	e8 cc 0d 00 00       	call   80104b10 <release>
    sti();
80103d44:	83 c4 10             	add    $0x10,%esp
80103d47:	eb 87                	jmp    80103cd0 <scheduler+0x20>
80103d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80103d50 <sched>:
{
80103d50:	55                   	push   %ebp
80103d51:	89 e5                	mov    %esp,%ebp
80103d53:	56                   	push   %esi
80103d54:	53                   	push   %ebx
  pushcli();
80103d55:	e8 c6 0c 00 00       	call   80104a20 <pushcli>
  c = mycpu();
80103d5a:	e8 d1 fb ff ff       	call   80103930 <mycpu>
  p = c->proc;
80103d5f:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103d65:	e8 06 0d 00 00       	call   80104a70 <popcli>
  if(!holding(&ptable.lock))
80103d6a:	83 ec 0c             	sub    $0xc,%esp
80103d6d:	68 20 2d 11 80       	push   $0x80112d20
80103d72:	e8 59 0d 00 00       	call   80104ad0 <holding>
80103d77:	83 c4 10             	add    $0x10,%esp
80103d7a:	85 c0                	test   %eax,%eax
80103d7c:	74 4f                	je     80103dcd <sched+0x7d>
  if(mycpu()->ncli != 1)
80103d7e:	e8 ad fb ff ff       	call   80103930 <mycpu>
80103d83:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103d8a:	75 68                	jne    80103df4 <sched+0xa4>
  if(p->state == RUNNING)
80103d8c:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103d90:	74 55                	je     80103de7 <sched+0x97>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d92:	9c                   	pushf  
80103d93:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103d94:	f6 c4 02             	test   $0x2,%ah
80103d97:	75 41                	jne    80103dda <sched+0x8a>
  intena = mycpu()->intena;
80103d99:	e8 92 fb ff ff       	call   80103930 <mycpu>
  swtch(&p->context, mycpu()->scheduler);
80103d9e:	83 c3 1c             	add    $0x1c,%ebx
  intena = mycpu()->intena;
80103da1:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103da7:	e8 84 fb ff ff       	call   80103930 <mycpu>
80103dac:	83 ec 08             	sub    $0x8,%esp
80103daf:	ff 70 04             	push   0x4(%eax)
80103db2:	53                   	push   %ebx
80103db3:	e8 93 10 00 00       	call   80104e4b <swtch>
  mycpu()->intena = intena;
80103db8:	e8 73 fb ff ff       	call   80103930 <mycpu>
}
80103dbd:	83 c4 10             	add    $0x10,%esp
  mycpu()->intena = intena;
80103dc0:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103dc6:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103dc9:	5b                   	pop    %ebx
80103dca:	5e                   	pop    %esi
80103dcb:	5d                   	pop    %ebp
80103dcc:	c3                   	ret    
    panic("sched ptable.lock");
80103dcd:	83 ec 0c             	sub    $0xc,%esp
80103dd0:	68 1b 81 10 80       	push   $0x8010811b
80103dd5:	e8 a6 c5 ff ff       	call   80100380 <panic>
    panic("sched interruptible");
80103dda:	83 ec 0c             	sub    $0xc,%esp
80103ddd:	68 47 81 10 80       	push   $0x80108147
80103de2:	e8 99 c5 ff ff       	call   80100380 <panic>
    panic("sched running");
80103de7:	83 ec 0c             	sub    $0xc,%esp
80103dea:	68 39 81 10 80       	push   $0x80108139
80103def:	e8 8c c5 ff ff       	call   80100380 <panic>
    panic("sched locks");
80103df4:	83 ec 0c             	sub    $0xc,%esp
80103df7:	68 2d 81 10 80       	push   $0x8010812d
80103dfc:	e8 7f c5 ff ff       	call   80100380 <panic>
80103e01:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103e08:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103e0f:	90                   	nop

80103e10 <exit>:
{
80103e10:	55                   	push   %ebp
80103e11:	89 e5                	mov    %esp,%ebp
80103e13:	57                   	push   %edi
80103e14:	56                   	push   %esi
80103e15:	53                   	push   %ebx
80103e16:	83 ec 0c             	sub    $0xc,%esp
  struct proc *curproc = myproc();
80103e19:	e8 92 fb ff ff       	call   801039b0 <myproc>
  if(curproc == initproc)
80103e1e:	39 05 54 9d 11 80    	cmp    %eax,0x80119d54
80103e24:	0f 84 07 01 00 00    	je     80103f31 <exit+0x121>
80103e2a:	89 c3                	mov    %eax,%ebx
80103e2c:	8d 70 28             	lea    0x28(%eax),%esi
80103e2f:	8d 78 68             	lea    0x68(%eax),%edi
80103e32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    if(curproc->ofile[fd]){
80103e38:	8b 06                	mov    (%esi),%eax
80103e3a:	85 c0                	test   %eax,%eax
80103e3c:	74 12                	je     80103e50 <exit+0x40>
      fileclose(curproc->ofile[fd]);
80103e3e:	83 ec 0c             	sub    $0xc,%esp
80103e41:	50                   	push   %eax
80103e42:	e8 b9 d0 ff ff       	call   80100f00 <fileclose>
      curproc->ofile[fd] = 0;
80103e47:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80103e4d:	83 c4 10             	add    $0x10,%esp
  for(fd = 0; fd < NOFILE; fd++){
80103e50:	83 c6 04             	add    $0x4,%esi
80103e53:	39 f7                	cmp    %esi,%edi
80103e55:	75 e1                	jne    80103e38 <exit+0x28>
  begin_op();
80103e57:	e8 14 ef ff ff       	call   80102d70 <begin_op>
  iput(curproc->cwd);
80103e5c:	83 ec 0c             	sub    $0xc,%esp
80103e5f:	ff 73 68             	push   0x68(%ebx)
80103e62:	e8 59 da ff ff       	call   801018c0 <iput>
  end_op();
80103e67:	e8 74 ef ff ff       	call   80102de0 <end_op>
  curproc->cwd = 0;
80103e6c:	c7 43 68 00 00 00 00 	movl   $0x0,0x68(%ebx)
  acquire(&ptable.lock);
80103e73:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80103e7a:	e8 f1 0c 00 00       	call   80104b70 <acquire>
  wakeup1(curproc->parent);
80103e7f:	8b 53 14             	mov    0x14(%ebx),%edx
80103e82:	83 c4 10             	add    $0x10,%esp
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103e85:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103e8a:	eb 10                	jmp    80103e9c <exit+0x8c>
80103e8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103e90:	05 c0 01 00 00       	add    $0x1c0,%eax
80103e95:	3d 54 9d 11 80       	cmp    $0x80119d54,%eax
80103e9a:	74 1e                	je     80103eba <exit+0xaa>
    if(p->state == SLEEPING && p->chan == chan)
80103e9c:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103ea0:	75 ee                	jne    80103e90 <exit+0x80>
80103ea2:	3b 50 20             	cmp    0x20(%eax),%edx
80103ea5:	75 e9                	jne    80103e90 <exit+0x80>
      p->state = RUNNABLE;
80103ea7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103eae:	05 c0 01 00 00       	add    $0x1c0,%eax
80103eb3:	3d 54 9d 11 80       	cmp    $0x80119d54,%eax
80103eb8:	75 e2                	jne    80103e9c <exit+0x8c>
      p->parent = initproc;
80103eba:	8b 0d 54 9d 11 80    	mov    0x80119d54,%ecx
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ec0:	ba 54 2d 11 80       	mov    $0x80112d54,%edx
80103ec5:	eb 17                	jmp    80103ede <exit+0xce>
80103ec7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80103ece:	66 90                	xchg   %ax,%ax
80103ed0:	81 c2 c0 01 00 00    	add    $0x1c0,%edx
80103ed6:	81 fa 54 9d 11 80    	cmp    $0x80119d54,%edx
80103edc:	74 3a                	je     80103f18 <exit+0x108>
    if(p->parent == curproc){
80103ede:	39 5a 14             	cmp    %ebx,0x14(%edx)
80103ee1:	75 ed                	jne    80103ed0 <exit+0xc0>
      if(p->state == ZOMBIE)
80103ee3:	83 7a 0c 05          	cmpl   $0x5,0xc(%edx)
      p->parent = initproc;
80103ee7:	89 4a 14             	mov    %ecx,0x14(%edx)
      if(p->state == ZOMBIE)
80103eea:	75 e4                	jne    80103ed0 <exit+0xc0>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103eec:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
80103ef1:	eb 11                	jmp    80103f04 <exit+0xf4>
80103ef3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103ef7:	90                   	nop
80103ef8:	05 c0 01 00 00       	add    $0x1c0,%eax
80103efd:	3d 54 9d 11 80       	cmp    $0x80119d54,%eax
80103f02:	74 cc                	je     80103ed0 <exit+0xc0>
    if(p->state == SLEEPING && p->chan == chan)
80103f04:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103f08:	75 ee                	jne    80103ef8 <exit+0xe8>
80103f0a:	3b 48 20             	cmp    0x20(%eax),%ecx
80103f0d:	75 e9                	jne    80103ef8 <exit+0xe8>
      p->state = RUNNABLE;
80103f0f:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103f16:	eb e0                	jmp    80103ef8 <exit+0xe8>
  curproc->state = ZOMBIE;
80103f18:	c7 43 0c 05 00 00 00 	movl   $0x5,0xc(%ebx)
  sched();
80103f1f:	e8 2c fe ff ff       	call   80103d50 <sched>
  panic("zombie exit");
80103f24:	83 ec 0c             	sub    $0xc,%esp
80103f27:	68 68 81 10 80       	push   $0x80108168
80103f2c:	e8 4f c4 ff ff       	call   80100380 <panic>
    panic("init exiting");
80103f31:	83 ec 0c             	sub    $0xc,%esp
80103f34:	68 5b 81 10 80       	push   $0x8010815b
80103f39:	e8 42 c4 ff ff       	call   80100380 <panic>
80103f3e:	66 90                	xchg   %ax,%ax

80103f40 <wait>:
{
80103f40:	55                   	push   %ebp
80103f41:	89 e5                	mov    %esp,%ebp
80103f43:	56                   	push   %esi
80103f44:	53                   	push   %ebx
  pushcli();
80103f45:	e8 d6 0a 00 00       	call   80104a20 <pushcli>
  c = mycpu();
80103f4a:	e8 e1 f9 ff ff       	call   80103930 <mycpu>
  p = c->proc;
80103f4f:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
80103f55:	e8 16 0b 00 00       	call   80104a70 <popcli>
  acquire(&ptable.lock);
80103f5a:	83 ec 0c             	sub    $0xc,%esp
80103f5d:	68 20 2d 11 80       	push   $0x80112d20
80103f62:	e8 09 0c 00 00       	call   80104b70 <acquire>
80103f67:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103f6a:	31 c0                	xor    %eax,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f6c:	bb 54 2d 11 80       	mov    $0x80112d54,%ebx
80103f71:	eb 13                	jmp    80103f86 <wait+0x46>
80103f73:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80103f77:	90                   	nop
80103f78:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
80103f7e:	81 fb 54 9d 11 80    	cmp    $0x80119d54,%ebx
80103f84:	74 1e                	je     80103fa4 <wait+0x64>
      if(p->parent != curproc)
80103f86:	39 73 14             	cmp    %esi,0x14(%ebx)
80103f89:	75 ed                	jne    80103f78 <wait+0x38>
      if(p->state == ZOMBIE){
80103f8b:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103f8f:	74 5f                	je     80103ff0 <wait+0xb0>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f91:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
      havekids = 1;
80103f97:	b8 01 00 00 00       	mov    $0x1,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103f9c:	81 fb 54 9d 11 80    	cmp    $0x80119d54,%ebx
80103fa2:	75 e2                	jne    80103f86 <wait+0x46>
    if(!havekids || curproc->killed){
80103fa4:	85 c0                	test   %eax,%eax
80103fa6:	0f 84 9a 00 00 00    	je     80104046 <wait+0x106>
80103fac:	8b 46 24             	mov    0x24(%esi),%eax
80103faf:	85 c0                	test   %eax,%eax
80103fb1:	0f 85 8f 00 00 00    	jne    80104046 <wait+0x106>
  pushcli();
80103fb7:	e8 64 0a 00 00       	call   80104a20 <pushcli>
  c = mycpu();
80103fbc:	e8 6f f9 ff ff       	call   80103930 <mycpu>
  p = c->proc;
80103fc1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103fc7:	e8 a4 0a 00 00       	call   80104a70 <popcli>
  if(p == 0)
80103fcc:	85 db                	test   %ebx,%ebx
80103fce:	0f 84 89 00 00 00    	je     8010405d <wait+0x11d>
  p->chan = chan;
80103fd4:	89 73 20             	mov    %esi,0x20(%ebx)
  p->state = SLEEPING;
80103fd7:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80103fde:	e8 6d fd ff ff       	call   80103d50 <sched>
  p->chan = 0;
80103fe3:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
80103fea:	e9 7b ff ff ff       	jmp    80103f6a <wait+0x2a>
80103fef:	90                   	nop
        kfree(p->kstack);
80103ff0:	83 ec 0c             	sub    $0xc,%esp
        pid = p->pid;
80103ff3:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103ff6:	ff 73 08             	push   0x8(%ebx)
80103ff9:	e8 d2 e4 ff ff       	call   801024d0 <kfree>
        p->kstack = 0;
80103ffe:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80104005:	5a                   	pop    %edx
80104006:	ff 73 04             	push   0x4(%ebx)
80104009:	e8 d2 37 00 00       	call   801077e0 <freevm>
        p->pid = 0;
8010400e:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80104015:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010401c:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80104020:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80104027:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010402e:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80104035:	e8 d6 0a 00 00       	call   80104b10 <release>
        return pid;
8010403a:	83 c4 10             	add    $0x10,%esp
}
8010403d:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104040:	89 f0                	mov    %esi,%eax
80104042:	5b                   	pop    %ebx
80104043:	5e                   	pop    %esi
80104044:	5d                   	pop    %ebp
80104045:	c3                   	ret    
      release(&ptable.lock);
80104046:	83 ec 0c             	sub    $0xc,%esp
      return -1;
80104049:	be ff ff ff ff       	mov    $0xffffffff,%esi
      release(&ptable.lock);
8010404e:	68 20 2d 11 80       	push   $0x80112d20
80104053:	e8 b8 0a 00 00       	call   80104b10 <release>
      return -1;
80104058:	83 c4 10             	add    $0x10,%esp
8010405b:	eb e0                	jmp    8010403d <wait+0xfd>
    panic("sleep");
8010405d:	83 ec 0c             	sub    $0xc,%esp
80104060:	68 74 81 10 80       	push   $0x80108174
80104065:	e8 16 c3 ff ff       	call   80100380 <panic>
8010406a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104070 <yield>:
{
80104070:	55                   	push   %ebp
80104071:	89 e5                	mov    %esp,%ebp
80104073:	53                   	push   %ebx
80104074:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104077:	68 20 2d 11 80       	push   $0x80112d20
8010407c:	e8 ef 0a 00 00       	call   80104b70 <acquire>
  pushcli();
80104081:	e8 9a 09 00 00       	call   80104a20 <pushcli>
  c = mycpu();
80104086:	e8 a5 f8 ff ff       	call   80103930 <mycpu>
  p = c->proc;
8010408b:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80104091:	e8 da 09 00 00       	call   80104a70 <popcli>
  myproc()->state = RUNNABLE;
80104096:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  sched();
8010409d:	e8 ae fc ff ff       	call   80103d50 <sched>
  release(&ptable.lock);
801040a2:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
801040a9:	e8 62 0a 00 00       	call   80104b10 <release>
}
801040ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040b1:	83 c4 10             	add    $0x10,%esp
801040b4:	c9                   	leave  
801040b5:	c3                   	ret    
801040b6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801040bd:	8d 76 00             	lea    0x0(%esi),%esi

801040c0 <sleep>:
{
801040c0:	55                   	push   %ebp
801040c1:	89 e5                	mov    %esp,%ebp
801040c3:	57                   	push   %edi
801040c4:	56                   	push   %esi
801040c5:	53                   	push   %ebx
801040c6:	83 ec 0c             	sub    $0xc,%esp
801040c9:	8b 7d 08             	mov    0x8(%ebp),%edi
801040cc:	8b 75 0c             	mov    0xc(%ebp),%esi
  pushcli();
801040cf:	e8 4c 09 00 00       	call   80104a20 <pushcli>
  c = mycpu();
801040d4:	e8 57 f8 ff ff       	call   80103930 <mycpu>
  p = c->proc;
801040d9:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801040df:	e8 8c 09 00 00       	call   80104a70 <popcli>
  if(p == 0)
801040e4:	85 db                	test   %ebx,%ebx
801040e6:	0f 84 87 00 00 00    	je     80104173 <sleep+0xb3>
  if(lk == 0)
801040ec:	85 f6                	test   %esi,%esi
801040ee:	74 76                	je     80104166 <sleep+0xa6>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801040f0:	81 fe 20 2d 11 80    	cmp    $0x80112d20,%esi
801040f6:	74 50                	je     80104148 <sleep+0x88>
    acquire(&ptable.lock);  //DOC: sleeplock1
801040f8:	83 ec 0c             	sub    $0xc,%esp
801040fb:	68 20 2d 11 80       	push   $0x80112d20
80104100:	e8 6b 0a 00 00       	call   80104b70 <acquire>
    release(lk);
80104105:	89 34 24             	mov    %esi,(%esp)
80104108:	e8 03 0a 00 00       	call   80104b10 <release>
  p->chan = chan;
8010410d:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
80104110:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104117:	e8 34 fc ff ff       	call   80103d50 <sched>
  p->chan = 0;
8010411c:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
    release(&ptable.lock);
80104123:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010412a:	e8 e1 09 00 00       	call   80104b10 <release>
    acquire(lk);
8010412f:	89 75 08             	mov    %esi,0x8(%ebp)
80104132:	83 c4 10             	add    $0x10,%esp
}
80104135:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104138:	5b                   	pop    %ebx
80104139:	5e                   	pop    %esi
8010413a:	5f                   	pop    %edi
8010413b:	5d                   	pop    %ebp
    acquire(lk);
8010413c:	e9 2f 0a 00 00       	jmp    80104b70 <acquire>
80104141:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  p->chan = chan;
80104148:	89 7b 20             	mov    %edi,0x20(%ebx)
  p->state = SLEEPING;
8010414b:	c7 43 0c 02 00 00 00 	movl   $0x2,0xc(%ebx)
  sched();
80104152:	e8 f9 fb ff ff       	call   80103d50 <sched>
  p->chan = 0;
80104157:	c7 43 20 00 00 00 00 	movl   $0x0,0x20(%ebx)
}
8010415e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104161:	5b                   	pop    %ebx
80104162:	5e                   	pop    %esi
80104163:	5f                   	pop    %edi
80104164:	5d                   	pop    %ebp
80104165:	c3                   	ret    
    panic("sleep without lk");
80104166:	83 ec 0c             	sub    $0xc,%esp
80104169:	68 7a 81 10 80       	push   $0x8010817a
8010416e:	e8 0d c2 ff ff       	call   80100380 <panic>
    panic("sleep");
80104173:	83 ec 0c             	sub    $0xc,%esp
80104176:	68 74 81 10 80       	push   $0x80108174
8010417b:	e8 00 c2 ff ff       	call   80100380 <panic>

80104180 <wakeup>:
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104180:	55                   	push   %ebp
80104181:	89 e5                	mov    %esp,%ebp
80104183:	53                   	push   %ebx
80104184:	83 ec 10             	sub    $0x10,%esp
80104187:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ptable.lock);
8010418a:	68 20 2d 11 80       	push   $0x80112d20
8010418f:	e8 dc 09 00 00       	call   80104b70 <acquire>
80104194:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104197:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
8010419c:	eb 0e                	jmp    801041ac <wakeup+0x2c>
8010419e:	66 90                	xchg   %ax,%ax
801041a0:	05 c0 01 00 00       	add    $0x1c0,%eax
801041a5:	3d 54 9d 11 80       	cmp    $0x80119d54,%eax
801041aa:	74 1e                	je     801041ca <wakeup+0x4a>
    if(p->state == SLEEPING && p->chan == chan)
801041ac:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801041b0:	75 ee                	jne    801041a0 <wakeup+0x20>
801041b2:	3b 58 20             	cmp    0x20(%eax),%ebx
801041b5:	75 e9                	jne    801041a0 <wakeup+0x20>
      p->state = RUNNABLE;
801041b7:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801041be:	05 c0 01 00 00       	add    $0x1c0,%eax
801041c3:	3d 54 9d 11 80       	cmp    $0x80119d54,%eax
801041c8:	75 e2                	jne    801041ac <wakeup+0x2c>
  wakeup1(chan);
  release(&ptable.lock);
801041ca:	c7 45 08 20 2d 11 80 	movl   $0x80112d20,0x8(%ebp)
}
801041d1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801041d4:	c9                   	leave  
  release(&ptable.lock);
801041d5:	e9 36 09 00 00       	jmp    80104b10 <release>
801041da:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801041e0 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801041e0:	55                   	push   %ebp
801041e1:	89 e5                	mov    %esp,%ebp
801041e3:	53                   	push   %ebx
801041e4:	83 ec 10             	sub    $0x10,%esp
801041e7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801041ea:	68 20 2d 11 80       	push   $0x80112d20
801041ef:	e8 7c 09 00 00       	call   80104b70 <acquire>
801041f4:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801041f7:	b8 54 2d 11 80       	mov    $0x80112d54,%eax
801041fc:	eb 0e                	jmp    8010420c <kill+0x2c>
801041fe:	66 90                	xchg   %ax,%ax
80104200:	05 c0 01 00 00       	add    $0x1c0,%eax
80104205:	3d 54 9d 11 80       	cmp    $0x80119d54,%eax
8010420a:	74 34                	je     80104240 <kill+0x60>
    if(p->pid == pid){
8010420c:	39 58 10             	cmp    %ebx,0x10(%eax)
8010420f:	75 ef                	jne    80104200 <kill+0x20>
      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104211:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
      p->killed = 1;
80104215:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      if(p->state == SLEEPING)
8010421c:	75 07                	jne    80104225 <kill+0x45>
        p->state = RUNNABLE;
8010421e:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80104225:	83 ec 0c             	sub    $0xc,%esp
80104228:	68 20 2d 11 80       	push   $0x80112d20
8010422d:	e8 de 08 00 00       	call   80104b10 <release>
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}
80104232:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return 0;
80104235:	83 c4 10             	add    $0x10,%esp
80104238:	31 c0                	xor    %eax,%eax
}
8010423a:	c9                   	leave  
8010423b:	c3                   	ret    
8010423c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  release(&ptable.lock);
80104240:	83 ec 0c             	sub    $0xc,%esp
80104243:	68 20 2d 11 80       	push   $0x80112d20
80104248:	e8 c3 08 00 00       	call   80104b10 <release>
}
8010424d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  return -1;
80104250:	83 c4 10             	add    $0x10,%esp
80104253:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104258:	c9                   	leave  
80104259:	c3                   	ret    
8010425a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104260 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80104260:	55                   	push   %ebp
80104261:	89 e5                	mov    %esp,%ebp
80104263:	57                   	push   %edi
80104264:	56                   	push   %esi
80104265:	8d 75 e8             	lea    -0x18(%ebp),%esi
80104268:	53                   	push   %ebx
80104269:	bb c0 2d 11 80       	mov    $0x80112dc0,%ebx
8010426e:	83 ec 3c             	sub    $0x3c,%esp
80104271:	eb 27                	jmp    8010429a <procdump+0x3a>
80104273:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104277:	90                   	nop
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80104278:	83 ec 0c             	sub    $0xc,%esp
8010427b:	68 63 85 10 80       	push   $0x80108563
80104280:	e8 1b c4 ff ff       	call   801006a0 <cprintf>
80104285:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104288:	81 c3 c0 01 00 00    	add    $0x1c0,%ebx
8010428e:	81 fb c0 9d 11 80    	cmp    $0x80119dc0,%ebx
80104294:	0f 84 7e 00 00 00    	je     80104318 <procdump+0xb8>
    if(p->state == UNUSED)
8010429a:	8b 43 a0             	mov    -0x60(%ebx),%eax
8010429d:	85 c0                	test   %eax,%eax
8010429f:	74 e7                	je     80104288 <procdump+0x28>
      state = "???";
801042a1:	ba 8b 81 10 80       	mov    $0x8010818b,%edx
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
801042a6:	83 f8 05             	cmp    $0x5,%eax
801042a9:	77 11                	ja     801042bc <procdump+0x5c>
801042ab:	8b 14 85 ec 81 10 80 	mov    -0x7fef7e14(,%eax,4),%edx
      state = "???";
801042b2:	b8 8b 81 10 80       	mov    $0x8010818b,%eax
801042b7:	85 d2                	test   %edx,%edx
801042b9:	0f 44 d0             	cmove  %eax,%edx
    cprintf("%d %s %s", p->pid, state, p->name);
801042bc:	53                   	push   %ebx
801042bd:	52                   	push   %edx
801042be:	ff 73 a4             	push   -0x5c(%ebx)
801042c1:	68 8f 81 10 80       	push   $0x8010818f
801042c6:	e8 d5 c3 ff ff       	call   801006a0 <cprintf>
    if(p->state == SLEEPING){
801042cb:	83 c4 10             	add    $0x10,%esp
801042ce:	83 7b a0 02          	cmpl   $0x2,-0x60(%ebx)
801042d2:	75 a4                	jne    80104278 <procdump+0x18>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801042d4:	83 ec 08             	sub    $0x8,%esp
801042d7:	8d 45 c0             	lea    -0x40(%ebp),%eax
801042da:	8d 7d c0             	lea    -0x40(%ebp),%edi
801042dd:	50                   	push   %eax
801042de:	8b 43 b0             	mov    -0x50(%ebx),%eax
801042e1:	8b 40 0c             	mov    0xc(%eax),%eax
801042e4:	83 c0 08             	add    $0x8,%eax
801042e7:	50                   	push   %eax
801042e8:	e8 d3 06 00 00       	call   801049c0 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
801042ed:	83 c4 10             	add    $0x10,%esp
801042f0:	8b 17                	mov    (%edi),%edx
801042f2:	85 d2                	test   %edx,%edx
801042f4:	74 82                	je     80104278 <procdump+0x18>
        cprintf(" %p", pc[i]);
801042f6:	83 ec 08             	sub    $0x8,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801042f9:	83 c7 04             	add    $0x4,%edi
        cprintf(" %p", pc[i]);
801042fc:	52                   	push   %edx
801042fd:	68 e1 7b 10 80       	push   $0x80107be1
80104302:	e8 99 c3 ff ff       	call   801006a0 <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80104307:	83 c4 10             	add    $0x10,%esp
8010430a:	39 fe                	cmp    %edi,%esi
8010430c:	75 e2                	jne    801042f0 <procdump+0x90>
8010430e:	e9 65 ff ff ff       	jmp    80104278 <procdump+0x18>
80104313:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104317:	90                   	nop
  }
}
80104318:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010431b:	5b                   	pop    %ebx
8010431c:	5e                   	pop    %esi
8010431d:	5f                   	pop    %edi
8010431e:	5d                   	pop    %ebp
8010431f:	c3                   	ret    

80104320 <wmap_helper>:
// Helper method for wmap
//
// Returns: 
//  Success: the starting virtual address of the memory
//  Fail: FAILED
int wmap_helper(uint addr, int length, int flags, int fd){
80104320:	55                   	push   %ebp
80104321:	89 e5                	mov    %esp,%ebp
80104323:	57                   	push   %edi
80104324:	56                   	push   %esi
80104325:	53                   	push   %ebx
80104326:	83 ec 1c             	sub    $0x1c,%esp
80104329:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010432c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pushcli();
8010432f:	e8 ec 06 00 00       	call   80104a20 <pushcli>
  c = mycpu();
80104334:	e8 f7 f5 ff ff       	call   80103930 <mycpu>
  p = c->proc;
80104339:	8b b0 ac 00 00 00    	mov    0xac(%eax),%esi
  popcli();
8010433f:	e8 2c 07 00 00       	call   80104a70 <popcli>
  //////////////////////////////
  // Check validity of inputs //
  //////////////////////////////

  // Addr must a multiple of page size and within 0x60000000 and 0x80000000
  if (addr % PAGE_SIZE != 0 || addr < 0x60000000 || addr >= 0x80000000) {
80104344:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
8010434a:	0f 85 f8 00 00 00    	jne    80104448 <wmap_helper+0x128>
80104350:	8d 83 00 00 00 a0    	lea    -0x60000000(%ebx),%eax
    // Address not page-aligned or out of allowed range
    return FAILED;
  }

  // length must be greater than 0
  if (length <= 0) {
80104356:	3d ff ff ff 1f       	cmp    $0x1fffffff,%eax
8010435b:	0f 87 e7 00 00 00    	ja     80104448 <wmap_helper+0x128>
80104361:	85 ff                	test   %edi,%edi
80104363:	0f 8e df 00 00 00    	jle    80104448 <wmap_helper+0x128>
  }

  // MAP_SHARED: Flag that tells wmap that the mapping is shared
  // MAP_FIXED: Flag that declares that the mapping MUST be placed at exactly addr
  // Return error if MAP_SHARED and MAP_FIXED not set
  if (!(flags & MAP_SHARED) || !(flags & MAP_FIXED)) {
80104369:	8b 45 10             	mov    0x10(%ebp),%eax
8010436c:	83 e0 0a             	and    $0xa,%eax
8010436f:	83 f8 0a             	cmp    $0xa,%eax
80104372:	0f 85 d0 00 00 00    	jne    80104448 <wmap_helper+0x128>
  }

  // MAP_ANONYMOUS: Flag that this is NOT a file-backed mapping, if set ignore fd
  // Otherwise assume fd belongs to a file of type FD_INODE and was opened in O_RDRW mode
  // File-backed mapping: expect the map size to be equal to the file size
  if (!(flags & MAP_ANONYMOUS)){
80104378:	f6 45 10 04          	testb  $0x4,0x10(%ebp)
8010437c:	0f 85 b6 00 00 00    	jne    80104438 <wmap_helper+0x118>
    // file-backed mapping
    if (fd < 0 || fd >= NOFILE) {
80104382:	83 7d 14 0f          	cmpl   $0xf,0x14(%ebp)
80104386:	0f 87 bc 00 00 00    	ja     80104448 <wmap_helper+0x128>
      return FAILED;  // invalid fd
    }

    // retrieve file pointer
    struct file *f = p->ofile[fd];
8010438c:	8b 45 14             	mov    0x14(%ebp),%eax
8010438f:	8b 44 86 28          	mov    0x28(%esi,%eax,4),%eax
    if (!f) {
80104393:	85 c0                	test   %eax,%eax
80104395:	0f 84 ad 00 00 00    	je     80104448 <wmap_helper+0x128>
      return FAILED;  // file not open
    }

    // ensure file is readable and writable
    if (!(f->readable && f->writable)) {
8010439b:	80 78 08 00          	cmpb   $0x0,0x8(%eax)
8010439f:	0f 84 a3 00 00 00    	je     80104448 <wmap_helper+0x128>
801043a5:	80 78 09 00          	cmpb   $0x0,0x9(%eax)
801043a9:	0f 84 99 00 00 00    	je     80104448 <wmap_helper+0x128>
      return FAILED;
    }

    ilock(f->ip);
801043af:	83 ec 0c             	sub    $0xc,%esp
801043b2:	ff 70 10             	push   0x10(%eax)
801043b5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801043b8:	e8 d3 d3 ff ff       	call   80101790 <ilock>
    if (length > f->ip->size) {
801043bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801043c0:	83 c4 10             	add    $0x10,%esp
801043c3:	8b 40 10             	mov    0x10(%eax),%eax
801043c6:	39 78 58             	cmp    %edi,0x58(%eax)
801043c9:	0f 82 97 00 00 00    	jb     80104466 <wmap_helper+0x146>
      iunlock(f->ip);
      return FAILED;  // Mapping length exceeds file size
    }
    iunlock(f->ip);  // Unlock the inode
801043cf:	83 ec 0c             	sub    $0xc,%esp
801043d2:	50                   	push   %eax
801043d3:	e8 98 d4 ff ff       	call   80101870 <iunlock>
801043d8:	83 c4 10             	add    $0x10,%esp
  }

  ///////////////////////////////////////////////////////
  // Check if we hit the maximum number of memory maps //
  ///////////////////////////////////////////////////////
  acquire(&ptable.lock);
801043db:	83 ec 0c             	sub    $0xc,%esp
801043de:	68 20 2d 11 80       	push   $0x80112d20
801043e3:	e8 88 07 00 00       	call   80104b70 <acquire>

  // Check if we allocate any more memory maps
  if (p->wmap_count >= MAX_NUM_WMAPS){
801043e8:	8b 86 bc 01 00 00    	mov    0x1bc(%esi),%eax
801043ee:	83 c4 10             	add    $0x10,%esp
801043f1:	83 f8 0f             	cmp    $0xf,%eax
801043f4:	7f 59                	jg     8010444f <wmap_helper+0x12f>

  // Track the mapping in `wmap_regions`
  struct wmap_region *region = &p->wmap_regions[p->wmap_count];
  region->addr = addr;
  region->length = length;
  region->fd = fd;
801043f6:	8b 4d 14             	mov    0x14(%ebp),%ecx
  region->addr = addr;
801043f9:	8d 14 80             	lea    (%eax,%eax,4),%edx
  p->wmap_count++;

  release(&ptable.lock);
801043fc:	83 ec 0c             	sub    $0xc,%esp
  p->wmap_count++;
801043ff:	83 c0 01             	add    $0x1,%eax
  region->addr = addr;
80104402:	8d 14 96             	lea    (%esi,%edx,4),%edx
80104405:	89 5a 7c             	mov    %ebx,0x7c(%edx)
  region->length = length;
80104408:	89 ba 80 00 00 00    	mov    %edi,0x80(%edx)
  region->fd = fd;
8010440e:	89 8a 88 00 00 00    	mov    %ecx,0x88(%edx)
  p->wmap_count++;
80104414:	89 86 bc 01 00 00    	mov    %eax,0x1bc(%esi)
  release(&ptable.lock);
8010441a:	68 20 2d 11 80       	push   $0x80112d20
8010441f:	e8 ec 06 00 00       	call   80104b10 <release>

  // Success: the starting virtual address of the memory
  return addr;
80104424:	89 d8                	mov    %ebx,%eax
80104426:	83 c4 10             	add    $0x10,%esp
}
80104429:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010442c:	5b                   	pop    %ebx
8010442d:	5e                   	pop    %esi
8010442e:	5f                   	pop    %edi
8010442f:	5d                   	pop    %ebp
80104430:	c3                   	ret    
80104431:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    fd = -1;  // ignore fd
80104438:	c7 45 14 ff ff ff ff 	movl   $0xffffffff,0x14(%ebp)
8010443f:	eb 9a                	jmp    801043db <wmap_helper+0xbb>
80104441:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return FAILED;
80104448:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010444d:	eb da                	jmp    80104429 <wmap_helper+0x109>
    release(&ptable.lock);
8010444f:	83 ec 0c             	sub    $0xc,%esp
80104452:	68 20 2d 11 80       	push   $0x80112d20
80104457:	e8 b4 06 00 00       	call   80104b10 <release>
    return FAILED;
8010445c:	83 c4 10             	add    $0x10,%esp
8010445f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104464:	eb c3                	jmp    80104429 <wmap_helper+0x109>
      iunlock(f->ip);
80104466:	83 ec 0c             	sub    $0xc,%esp
80104469:	50                   	push   %eax
8010446a:	e8 01 d4 ff ff       	call   80101870 <iunlock>
      return FAILED;  // Mapping length exceeds file size
8010446f:	83 c4 10             	add    $0x10,%esp
80104472:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104477:	eb b0                	jmp    80104429 <wmap_helper+0x109>
80104479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104480 <valid_memory_mapping_index>:

// Helper function called by kernel to check if valid memory mapping
// Success: returns wmap region index
// Fail: returns -1
uint valid_memory_mapping_index(struct proc *p, uint faulting_addr){
80104480:	55                   	push   %ebp
80104481:	89 e5                	mov    %esp,%ebp
80104483:	57                   	push   %edi
80104484:	56                   	push   %esi
80104485:	53                   	push   %ebx
80104486:	83 ec 18             	sub    $0x18,%esp
80104489:	8b 5d 08             	mov    0x8(%ebp),%ebx
8010448c:	8b 75 0c             	mov    0xc(%ebp),%esi
  acquire(&ptable.lock);
8010448f:	68 20 2d 11 80       	push   $0x80112d20
80104494:	e8 d7 06 00 00       	call   80104b70 <acquire>
  // Iterate through the process's memory regions (wmap_regions)
  for (int i = 0; i < p->wmap_count; i++) {
80104499:	8b bb bc 01 00 00    	mov    0x1bc(%ebx),%edi
8010449f:	83 c4 10             	add    $0x10,%esp
801044a2:	85 ff                	test   %edi,%edi
801044a4:	7e 21                	jle    801044c7 <valid_memory_mapping_index+0x47>
801044a6:	8d 53 7c             	lea    0x7c(%ebx),%edx
801044a9:	31 db                	xor    %ebx,%ebx
801044ab:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801044af:	90                   	nop
    uint start_addr = p->wmap_regions[i].addr;
801044b0:	8b 0a                	mov    (%edx),%ecx
    int length = p->wmap_regions[i].length;

    // Check if the faulting address is within the bounds of this memory region
    if (faulting_addr >= start_addr && faulting_addr < start_addr + length) {
801044b2:	39 f1                	cmp    %esi,%ecx
801044b4:	77 07                	ja     801044bd <valid_memory_mapping_index+0x3d>
801044b6:	03 4a 04             	add    0x4(%edx),%ecx
801044b9:	39 f1                	cmp    %esi,%ecx
801044bb:	77 2b                	ja     801044e8 <valid_memory_mapping_index+0x68>
  for (int i = 0; i < p->wmap_count; i++) {
801044bd:	83 c3 01             	add    $0x1,%ebx
801044c0:	83 c2 14             	add    $0x14,%edx
801044c3:	39 fb                	cmp    %edi,%ebx
801044c5:	75 e9                	jne    801044b0 <valid_memory_mapping_index+0x30>
      return i;
    }
  }

  // Fail: address not found within bounds
  release(&ptable.lock);
801044c7:	83 ec 0c             	sub    $0xc,%esp
801044ca:	68 20 2d 11 80       	push   $0x80112d20
801044cf:	e8 3c 06 00 00       	call   80104b10 <release>
  return -1;
801044d4:	83 c4 10             	add    $0x10,%esp
}
801044d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return -1;
801044da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801044df:	5b                   	pop    %ebx
801044e0:	5e                   	pop    %esi
801044e1:	5f                   	pop    %edi
801044e2:	5d                   	pop    %ebp
801044e3:	c3                   	ret    
801044e4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      release(&ptable.lock);
801044e8:	83 ec 0c             	sub    $0xc,%esp
801044eb:	68 20 2d 11 80       	push   $0x80112d20
801044f0:	e8 1b 06 00 00       	call   80104b10 <release>
      return i;
801044f5:	83 c4 10             	add    $0x10,%esp
}
801044f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return i;
801044fb:	89 d8                	mov    %ebx,%eax
}
801044fd:	5b                   	pop    %ebx
801044fe:	5e                   	pop    %esi
801044ff:	5f                   	pop    %edi
80104500:	5d                   	pop    %ebp
80104501:	c3                   	ret    
80104502:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104509:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104510 <wunmap_helper>:

// helper function for wunmap
// returns 0 upon success, -1 upon fail
int wunmap_helper(uint addr) {
80104510:	55                   	push   %ebp
80104511:	89 e5                	mov    %esp,%ebp
80104513:	57                   	push   %edi
80104514:	56                   	push   %esi
80104515:	53                   	push   %ebx
80104516:	83 ec 1c             	sub    $0x1c,%esp
80104519:	8b 75 08             	mov    0x8(%ebp),%esi
  pushcli();
8010451c:	e8 ff 04 00 00       	call   80104a20 <pushcli>
  c = mycpu();
80104521:	e8 0a f4 ff ff       	call   80103930 <mycpu>
  p = c->proc;
80104526:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010452c:	e8 3f 05 00 00       	call   80104a70 <popcli>
  struct proc *p = myproc();  // current process
  int region_index = -1;

  acquire(&ptable.lock);
80104531:	83 ec 0c             	sub    $0xc,%esp
80104534:	68 20 2d 11 80       	push   $0x80112d20
80104539:	e8 32 06 00 00       	call   80104b70 <acquire>
  // find mapping starting at addr
  for (int i = 0; i < p->wmap_count; i++) {
8010453e:	8b 93 bc 01 00 00    	mov    0x1bc(%ebx),%edx
80104544:	83 c4 10             	add    $0x10,%esp
80104547:	85 d2                	test   %edx,%edx
80104549:	0f 8e 19 02 00 00    	jle    80104768 <wunmap_helper+0x258>
8010454f:	8d 43 7c             	lea    0x7c(%ebx),%eax
80104552:	31 c9                	xor    %ecx,%ecx
80104554:	eb 18                	jmp    8010456e <wunmap_helper+0x5e>
80104556:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010455d:	8d 76 00             	lea    0x0(%esi),%esi
80104560:	83 c1 01             	add    $0x1,%ecx
80104563:	83 c0 14             	add    $0x14,%eax
80104566:	39 d1                	cmp    %edx,%ecx
80104568:	0f 84 fa 01 00 00    	je     80104768 <wunmap_helper+0x258>
    if (p->wmap_regions[i].addr == addr) {
8010456e:	39 30                	cmp    %esi,(%eax)
80104570:	75 ee                	jne    80104560 <wunmap_helper+0x50>

  // struct of region for easy data access
  struct wmap_region *region = &p->wmap_regions[region_index];

  // write back to disk for file-backed mappings
  if (region->fd >= 0) {
80104572:	8d 3c 89             	lea    (%ecx,%ecx,4),%edi
80104575:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80104578:	8d 04 bb             	lea    (%ebx,%edi,4),%eax
8010457b:	8b 88 88 00 00 00    	mov    0x88(%eax),%ecx
80104581:	85 c9                	test   %ecx,%ecx
80104583:	0f 88 f6 00 00 00    	js     8010467f <wunmap_helper+0x16f>
    struct file *f = p->ofile[region->fd];
80104589:	8b 4c 8b 28          	mov    0x28(%ebx,%ecx,4),%ecx
8010458d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
    // validate file
    if (!f || f->type != FD_INODE || !(f->readable && f->writable)) {
80104590:	85 c9                	test   %ecx,%ecx
80104592:	0f 84 d0 01 00 00    	je     80104768 <wunmap_helper+0x258>
80104598:	83 39 02             	cmpl   $0x2,(%ecx)
8010459b:	0f 85 c7 01 00 00    	jne    80104768 <wunmap_helper+0x258>
801045a1:	80 79 08 00          	cmpb   $0x0,0x8(%ecx)
801045a5:	0f 84 bd 01 00 00    	je     80104768 <wunmap_helper+0x258>
801045ab:	80 79 09 00          	cmpb   $0x0,0x9(%ecx)
801045af:	0f 84 b3 01 00 00    	je     80104768 <wunmap_helper+0x258>
801045b5:	89 45 dc             	mov    %eax,-0x24(%ebp)
      release(&ptable.lock);
      return FAILED;  // invalid file/not writable or readable
    }
    // lock inode for consistency when writing back changes
    ilock(f->ip);
801045b8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801045bb:	83 ec 0c             	sub    $0xc,%esp
801045be:	ff 70 10             	push   0x10(%eax)
801045c1:	e8 ca d1 ff ff       	call   80101790 <ilock>
    
    // for each page in region, write back changes to file
    for (uint va = region->addr; va < region->addr + region->length; va += PAGE_SIZE) {
801045c6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801045c9:	83 c4 10             	add    $0x10,%esp
801045cc:	8b 70 7c             	mov    0x7c(%eax),%esi
801045cf:	8b 88 80 00 00 00    	mov    0x80(%eax),%ecx
801045d5:	01 f1                	add    %esi,%ecx
801045d7:	39 ce                	cmp    %ecx,%esi
801045d9:	72 1a                	jb     801045f5 <wunmap_helper+0xe5>
801045db:	e9 88 00 00 00       	jmp    80104668 <wunmap_helper+0x158>
801045e0:	8b 44 bb 7c          	mov    0x7c(%ebx,%edi,4),%eax
801045e4:	81 c6 00 10 00 00    	add    $0x1000,%esi
801045ea:	03 84 bb 80 00 00 00 	add    0x80(%ebx,%edi,4),%eax
801045f1:	39 f0                	cmp    %esi,%eax
801045f3:	76 73                	jbe    80104668 <wunmap_helper+0x158>
      pte_t *pte = walkpgdir(p->pgdir, (void *)va, 0);  // get pte for page
801045f5:	83 ec 04             	sub    $0x4,%esp
801045f8:	6a 00                	push   $0x0
801045fa:	56                   	push   %esi
801045fb:	ff 73 04             	push   0x4(%ebx)
801045fe:	e8 5d 2c 00 00       	call   80107260 <walkpgdir>
      if (pte && (*pte & PTE_P)) {  // page exists in mem
80104603:	83 c4 10             	add    $0x10,%esp
80104606:	85 c0                	test   %eax,%eax
80104608:	74 d6                	je     801045e0 <wunmap_helper+0xd0>
8010460a:	8b 00                	mov    (%eax),%eax
        uint physical_addr = PTE_ADDR(*pte);
        char *mem = (char*)P2V(physical_addr);

        // write page content back to file (offset always 0)
        if (writei(f->ip, mem, va - region->addr, PAGE_SIZE) != PAGE_SIZE) {
8010460c:	8b 54 bb 7c          	mov    0x7c(%ebx,%edi,4),%edx
      if (pte && (*pte & PTE_P)) {  // page exists in mem
80104610:	a8 01                	test   $0x1,%al
80104612:	74 cc                	je     801045e0 <wunmap_helper+0xd0>
        if (writei(f->ip, mem, va - region->addr, PAGE_SIZE) != PAGE_SIZE) {
80104614:	89 f1                	mov    %esi,%ecx
        uint physical_addr = PTE_ADDR(*pte);
80104616:	25 00 f0 ff ff       	and    $0xfffff000,%eax
        if (writei(f->ip, mem, va - region->addr, PAGE_SIZE) != PAGE_SIZE) {
8010461b:	68 00 10 00 00       	push   $0x1000
80104620:	29 d1                	sub    %edx,%ecx
        char *mem = (char*)P2V(physical_addr);
80104622:	05 00 00 00 80       	add    $0x80000000,%eax
        if (writei(f->ip, mem, va - region->addr, PAGE_SIZE) != PAGE_SIZE) {
80104627:	51                   	push   %ecx
80104628:	50                   	push   %eax
80104629:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010462c:	ff 70 10             	push   0x10(%eax)
8010462f:	e8 6c d5 ff ff       	call   80101ba0 <writei>
80104634:	83 c4 10             	add    $0x10,%esp
80104637:	3d 00 10 00 00       	cmp    $0x1000,%eax
8010463c:	74 a2                	je     801045e0 <wunmap_helper+0xd0>
          iunlock(f->ip); // failed to write back page to file
8010463e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104641:	83 ec 0c             	sub    $0xc,%esp
80104644:	ff 70 10             	push   0x10(%eax)
80104647:	e8 24 d2 ff ff       	call   80101870 <iunlock>
          release(&ptable.lock);
8010464c:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
80104653:	e8 b8 04 00 00       	call   80104b10 <release>
          return FAILED;
80104658:	83 c4 10             	add    $0x10,%esp
8010465b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104660:	e9 f5 00 00 00       	jmp    8010475a <wunmap_helper+0x24a>
80104665:	8d 76 00             	lea    0x0(%esi),%esi
        }
      }
    }
    iunlock(f->ip);
80104668:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010466b:	83 ec 0c             	sub    $0xc,%esp
8010466e:	ff 70 10             	push   0x10(%eax)
80104671:	e8 fa d1 ff ff       	call   80101870 <iunlock>
  }

  // remove mapping from proc's memory regions
  for (int i = region_index; i < p->wmap_count - 1; i++) {
80104676:	8b 93 bc 01 00 00    	mov    0x1bc(%ebx),%edx
8010467c:	83 c4 10             	add    $0x10,%esp
8010467f:	8d 4a ff             	lea    -0x1(%edx),%ecx
80104682:	39 4d e0             	cmp    %ecx,-0x20(%ebp)
80104685:	7d 3e                	jge    801046c5 <wunmap_helper+0x1b5>
80104687:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010468a:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010468d:	8d 74 93 68          	lea    0x68(%ebx,%edx,4),%esi
80104691:	8d 04 80             	lea    (%eax,%eax,4),%eax
80104694:	8d 44 83 7c          	lea    0x7c(%ebx,%eax,4),%eax
80104698:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010469f:	90                   	nop
    p->wmap_regions[i] = p->wmap_regions[i + 1];
801046a0:	8b 50 14             	mov    0x14(%eax),%edx
  for (int i = region_index; i < p->wmap_count - 1; i++) {
801046a3:	83 c0 14             	add    $0x14,%eax
    p->wmap_regions[i] = p->wmap_regions[i + 1];
801046a6:	89 50 ec             	mov    %edx,-0x14(%eax)
801046a9:	8b 50 04             	mov    0x4(%eax),%edx
801046ac:	89 50 f0             	mov    %edx,-0x10(%eax)
801046af:	8b 50 08             	mov    0x8(%eax),%edx
801046b2:	89 50 f4             	mov    %edx,-0xc(%eax)
801046b5:	8b 50 0c             	mov    0xc(%eax),%edx
801046b8:	89 50 f8             	mov    %edx,-0x8(%eax)
801046bb:	8b 50 10             	mov    0x10(%eax),%edx
801046be:	89 50 fc             	mov    %edx,-0x4(%eax)
  for (int i = region_index; i < p->wmap_count - 1; i++) {
801046c1:	39 f0                	cmp    %esi,%eax
801046c3:	75 db                	jne    801046a0 <wunmap_helper+0x190>
  }
  p->wmap_count--;

  // remove mapping from page table
  for (uint curr_addr = region->addr; curr_addr < region->addr + region->length; curr_addr += PAGE_SIZE) {
801046c5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  p->wmap_count--;
801046c8:	89 8b bc 01 00 00    	mov    %ecx,0x1bc(%ebx)
  for (uint curr_addr = region->addr; curr_addr < region->addr + region->length; curr_addr += PAGE_SIZE) {
801046ce:	8d 04 80             	lea    (%eax,%eax,4),%eax
801046d1:	8d 3c 83             	lea    (%ebx,%eax,4),%edi
801046d4:	8b 77 7c             	mov    0x7c(%edi),%esi
801046d7:	8b 87 80 00 00 00    	mov    0x80(%edi),%eax
801046dd:	01 f0                	add    %esi,%eax
801046df:	39 c6                	cmp    %eax,%esi
801046e1:	72 18                	jb     801046fb <wunmap_helper+0x1eb>
801046e3:	eb 63                	jmp    80104748 <wunmap_helper+0x238>
801046e5:	8d 76 00             	lea    0x0(%esi),%esi
801046e8:	8b 87 80 00 00 00    	mov    0x80(%edi),%eax
801046ee:	81 c6 00 10 00 00    	add    $0x1000,%esi
801046f4:	03 47 7c             	add    0x7c(%edi),%eax
801046f7:	39 f0                	cmp    %esi,%eax
801046f9:	76 4d                	jbe    80104748 <wunmap_helper+0x238>
    uint pdx = PDX(curr_addr);
    uint ptx = PTX(curr_addr);

    // Get the page table entry from the page directory (pgdir)
    pde_t *pde = &p->pgdir[pdx];  // Get the page directory entry for the address
    if (*pde & PTE_P) {  // Check if the page directory entry is present
801046fb:	8b 43 04             	mov    0x4(%ebx),%eax
    uint pdx = PDX(curr_addr);
801046fe:	89 f2                	mov    %esi,%edx
80104700:	c1 ea 16             	shr    $0x16,%edx
    if (*pde & PTE_P) {  // Check if the page directory entry is present
80104703:	8b 04 90             	mov    (%eax,%edx,4),%eax
80104706:	a8 01                	test   $0x1,%al
80104708:	74 de                	je     801046e8 <wunmap_helper+0x1d8>
    uint ptx = PTX(curr_addr);
8010470a:	89 f2                	mov    %esi,%edx
      pte_t *pt = (pte_t*)P2V(PTE_ADDR(*pde));  // Get the physical address of the page table
8010470c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    uint ptx = PTX(curr_addr);
80104711:	c1 ea 0a             	shr    $0xa,%edx
      pte_t *pte = &pt[ptx];  // Get the page table entry for the address
80104714:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
8010471a:	8d 94 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%edx

      if (*pte & PTE_P) {  // Check if the page table entry is valid and page is present in memory
80104721:	8b 02                	mov    (%edx),%eax
80104723:	a8 01                	test   $0x1,%al
80104725:	74 c1                	je     801046e8 <wunmap_helper+0x1d8>
        uint physical_addr = PTE_ADDR(*pte);  // Get physical address from the PTE
80104727:	25 00 f0 ff ff       	and    $0xfffff000,%eax
        *pte = 0;  // Clear the PTE (unmap the page)
        kfree(P2V(physical_addr));  // Free the physical page mapped to this virtual address
8010472c:	83 ec 0c             	sub    $0xc,%esp
        *pte = 0;  // Clear the PTE (unmap the page)
8010472f:	c7 02 00 00 00 00    	movl   $0x0,(%edx)
        kfree(P2V(physical_addr));  // Free the physical page mapped to this virtual address
80104735:	05 00 00 00 80       	add    $0x80000000,%eax
8010473a:	50                   	push   %eax
8010473b:	e8 90 dd ff ff       	call   801024d0 <kfree>
80104740:	83 c4 10             	add    $0x10,%esp
80104743:	eb a3                	jmp    801046e8 <wunmap_helper+0x1d8>
80104745:	8d 76 00             	lea    0x0(%esi),%esi
      }
    }
  }

  release(&ptable.lock);
80104748:	83 ec 0c             	sub    $0xc,%esp
8010474b:	68 20 2d 11 80       	push   $0x80112d20
80104750:	e8 bb 03 00 00       	call   80104b10 <release>
  return SUCCESS;
80104755:	83 c4 10             	add    $0x10,%esp
80104758:	31 c0                	xor    %eax,%eax

}
8010475a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010475d:	5b                   	pop    %ebx
8010475e:	5e                   	pop    %esi
8010475f:	5f                   	pop    %edi
80104760:	5d                   	pop    %ebp
80104761:	c3                   	ret    
80104762:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      release(&ptable.lock);
80104768:	83 ec 0c             	sub    $0xc,%esp
8010476b:	68 20 2d 11 80       	push   $0x80112d20
80104770:	e8 9b 03 00 00       	call   80104b10 <release>
      return FAILED;  // invalid file/not writable or readable
80104775:	83 c4 10             	add    $0x10,%esp
80104778:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010477d:	eb db                	jmp    8010475a <wunmap_helper+0x24a>
8010477f:	90                   	nop

80104780 <getwmapinfo_helper>:

int getwmapinfo_helper(struct proc *p, struct wmapinfo *wminfo) {
80104780:	55                   	push   %ebp
80104781:	89 e5                	mov    %esp,%ebp
80104783:	57                   	push   %edi
80104784:	56                   	push   %esi
80104785:	53                   	push   %ebx
80104786:	83 ec 20             	sub    $0x20,%esp
  // initialize wminfo struct
  memset(wminfo, 0, sizeof(struct wmapinfo));
80104789:	68 c4 00 00 00       	push   $0xc4
8010478e:	6a 00                	push   $0x0
80104790:	ff 75 0c             	push   0xc(%ebp)
80104793:	e8 98 04 00 00       	call   80104c30 <memset>

  acquire(&ptable.lock);
80104798:	c7 04 24 20 2d 11 80 	movl   $0x80112d20,(%esp)
8010479f:	e8 cc 03 00 00       	call   80104b70 <acquire>

  // iterate over active memory mappings
  for (int i = 0; i < p->wmap_count && i < MAX_WMMAP_INFO; i++) {
801047a4:	8b 45 08             	mov    0x8(%ebp),%eax
801047a7:	83 c4 10             	add    $0x10,%esp
801047aa:	8b 80 bc 01 00 00    	mov    0x1bc(%eax),%eax
801047b0:	85 c0                	test   %eax,%eax
801047b2:	0f 8e 8f 00 00 00    	jle    80104847 <getwmapinfo_helper+0xc7>
801047b8:	8b 45 08             	mov    0x8(%ebp),%eax
801047bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801047c2:	83 c0 7c             	add    $0x7c,%eax
801047c5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801047c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801047cb:	8d 78 04             	lea    0x4(%eax),%edi
801047ce:	66 90                	xchg   %ax,%ax
    // get address and length
    wminfo->addr[i] = (uint)p->wmap_regions[i].addr;
801047d0:	8b 45 e0             	mov    -0x20(%ebp),%eax
    wminfo->length[i] = p->wmap_regions[i].length;

    // count loaded pages for this region
    int loaded_pages = 0;
801047d3:	31 db                	xor    %ebx,%ebx
    wminfo->addr[i] = (uint)p->wmap_regions[i].addr;
801047d5:	8b 30                	mov    (%eax),%esi
801047d7:	89 37                	mov    %esi,(%edi)
    wminfo->length[i] = p->wmap_regions[i].length;
801047d9:	8b 40 04             	mov    0x4(%eax),%eax
801047dc:	89 47 40             	mov    %eax,0x40(%edi)
    for (uint va = wminfo->addr[i]; va < wminfo->addr[i] + wminfo->length[i]; va += PAGE_SIZE) {
801047df:	01 f0                	add    %esi,%eax
801047e1:	39 c6                	cmp    %eax,%esi
801047e3:	73 3f                	jae    80104824 <getwmapinfo_helper+0xa4>
    int loaded_pages = 0;
801047e5:	89 f0                	mov    %esi,%eax
801047e7:	89 fe                	mov    %edi,%esi
801047e9:	89 c7                	mov    %eax,%edi
801047eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801047ef:	90                   	nop
      pte_t *pte = walkpgdir(p->pgdir, (void *)va, 0);  // get pte for page
801047f0:	8b 45 08             	mov    0x8(%ebp),%eax
801047f3:	83 ec 04             	sub    $0x4,%esp
801047f6:	6a 00                	push   $0x0
801047f8:	57                   	push   %edi
801047f9:	ff 70 04             	push   0x4(%eax)
801047fc:	e8 5f 2a 00 00       	call   80107260 <walkpgdir>
      if (pte && (*pte & PTE_P)) {  // pte exists
80104801:	83 c4 10             	add    $0x10,%esp
80104804:	85 c0                	test   %eax,%eax
80104806:	74 0b                	je     80104813 <getwmapinfo_helper+0x93>
80104808:	8b 00                	mov    (%eax),%eax
8010480a:	83 e0 01             	and    $0x1,%eax
        loaded_pages++;
8010480d:	83 f8 01             	cmp    $0x1,%eax
80104810:	83 db ff             	sbb    $0xffffffff,%ebx
    for (uint va = wminfo->addr[i]; va < wminfo->addr[i] + wminfo->length[i]; va += PAGE_SIZE) {
80104813:	8b 46 40             	mov    0x40(%esi),%eax
80104816:	81 c7 00 10 00 00    	add    $0x1000,%edi
8010481c:	03 06                	add    (%esi),%eax
8010481e:	39 f8                	cmp    %edi,%eax
80104820:	77 ce                	ja     801047f0 <getwmapinfo_helper+0x70>
80104822:	89 f7                	mov    %esi,%edi
  for (int i = 0; i < p->wmap_count && i < MAX_WMMAP_INFO; i++) {
80104824:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104828:	8b 45 08             	mov    0x8(%ebp),%eax
8010482b:	83 c7 04             	add    $0x4,%edi
8010482e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
      }
    }
    wminfo->n_loaded_pages[i] = loaded_pages;
80104831:	89 5f 7c             	mov    %ebx,0x7c(%edi)
  for (int i = 0; i < p->wmap_count && i < MAX_WMMAP_INFO; i++) {
80104834:	83 45 e0 14          	addl   $0x14,-0x20(%ebp)
80104838:	8b 80 bc 01 00 00    	mov    0x1bc(%eax),%eax
8010483e:	83 fa 10             	cmp    $0x10,%edx
80104841:	74 04                	je     80104847 <getwmapinfo_helper+0xc7>
80104843:	39 d0                	cmp    %edx,%eax
80104845:	7f 89                	jg     801047d0 <getwmapinfo_helper+0x50>
  }

  // set total number of memory mappings
  wminfo->total_mmaps = p->wmap_count;
80104847:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  
  release(&ptable.lock);
8010484a:	83 ec 0c             	sub    $0xc,%esp
  wminfo->total_mmaps = p->wmap_count;
8010484d:	89 01                	mov    %eax,(%ecx)
  release(&ptable.lock);
8010484f:	68 20 2d 11 80       	push   $0x80112d20
80104854:	e8 b7 02 00 00       	call   80104b10 <release>

  // success
  return SUCCESS;
80104859:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010485c:	31 c0                	xor    %eax,%eax
8010485e:	5b                   	pop    %ebx
8010485f:	5e                   	pop    %esi
80104860:	5f                   	pop    %edi
80104861:	5d                   	pop    %ebp
80104862:	c3                   	ret    
80104863:	66 90                	xchg   %ax,%ax
80104865:	66 90                	xchg   %ax,%ax
80104867:	66 90                	xchg   %ax,%ax
80104869:	66 90                	xchg   %ax,%ax
8010486b:	66 90                	xchg   %ax,%ax
8010486d:	66 90                	xchg   %ax,%ax
8010486f:	90                   	nop

80104870 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80104870:	55                   	push   %ebp
80104871:	89 e5                	mov    %esp,%ebp
80104873:	53                   	push   %ebx
80104874:	83 ec 0c             	sub    $0xc,%esp
80104877:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010487a:	68 04 82 10 80       	push   $0x80108204
8010487f:	8d 43 04             	lea    0x4(%ebx),%eax
80104882:	50                   	push   %eax
80104883:	e8 18 01 00 00       	call   801049a0 <initlock>
  lk->name = name;
80104888:	8b 45 0c             	mov    0xc(%ebp),%eax
  lk->locked = 0;
8010488b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
}
80104891:	83 c4 10             	add    $0x10,%esp
  lk->pid = 0;
80104894:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  lk->name = name;
8010489b:	89 43 38             	mov    %eax,0x38(%ebx)
}
8010489e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801048a1:	c9                   	leave  
801048a2:	c3                   	ret    
801048a3:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801048aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

801048b0 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801048b0:	55                   	push   %ebp
801048b1:	89 e5                	mov    %esp,%ebp
801048b3:	56                   	push   %esi
801048b4:	53                   	push   %ebx
801048b5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801048b8:	8d 73 04             	lea    0x4(%ebx),%esi
801048bb:	83 ec 0c             	sub    $0xc,%esp
801048be:	56                   	push   %esi
801048bf:	e8 ac 02 00 00       	call   80104b70 <acquire>
  while (lk->locked) {
801048c4:	8b 13                	mov    (%ebx),%edx
801048c6:	83 c4 10             	add    $0x10,%esp
801048c9:	85 d2                	test   %edx,%edx
801048cb:	74 16                	je     801048e3 <acquiresleep+0x33>
801048cd:	8d 76 00             	lea    0x0(%esi),%esi
    sleep(lk, &lk->lk);
801048d0:	83 ec 08             	sub    $0x8,%esp
801048d3:	56                   	push   %esi
801048d4:	53                   	push   %ebx
801048d5:	e8 e6 f7 ff ff       	call   801040c0 <sleep>
  while (lk->locked) {
801048da:	8b 03                	mov    (%ebx),%eax
801048dc:	83 c4 10             	add    $0x10,%esp
801048df:	85 c0                	test   %eax,%eax
801048e1:	75 ed                	jne    801048d0 <acquiresleep+0x20>
  }
  lk->locked = 1;
801048e3:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801048e9:	e8 c2 f0 ff ff       	call   801039b0 <myproc>
801048ee:	8b 40 10             	mov    0x10(%eax),%eax
801048f1:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801048f4:	89 75 08             	mov    %esi,0x8(%ebp)
}
801048f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801048fa:	5b                   	pop    %ebx
801048fb:	5e                   	pop    %esi
801048fc:	5d                   	pop    %ebp
  release(&lk->lk);
801048fd:	e9 0e 02 00 00       	jmp    80104b10 <release>
80104902:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104909:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104910 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80104910:	55                   	push   %ebp
80104911:	89 e5                	mov    %esp,%ebp
80104913:	56                   	push   %esi
80104914:	53                   	push   %ebx
80104915:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80104918:	8d 73 04             	lea    0x4(%ebx),%esi
8010491b:	83 ec 0c             	sub    $0xc,%esp
8010491e:	56                   	push   %esi
8010491f:	e8 4c 02 00 00       	call   80104b70 <acquire>
  lk->locked = 0;
80104924:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
8010492a:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80104931:	89 1c 24             	mov    %ebx,(%esp)
80104934:	e8 47 f8 ff ff       	call   80104180 <wakeup>
  release(&lk->lk);
80104939:	89 75 08             	mov    %esi,0x8(%ebp)
8010493c:	83 c4 10             	add    $0x10,%esp
}
8010493f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104942:	5b                   	pop    %ebx
80104943:	5e                   	pop    %esi
80104944:	5d                   	pop    %ebp
  release(&lk->lk);
80104945:	e9 c6 01 00 00       	jmp    80104b10 <release>
8010494a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104950 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80104950:	55                   	push   %ebp
80104951:	89 e5                	mov    %esp,%ebp
80104953:	57                   	push   %edi
80104954:	31 ff                	xor    %edi,%edi
80104956:	56                   	push   %esi
80104957:	53                   	push   %ebx
80104958:	83 ec 18             	sub    $0x18,%esp
8010495b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
8010495e:	8d 73 04             	lea    0x4(%ebx),%esi
80104961:	56                   	push   %esi
80104962:	e8 09 02 00 00       	call   80104b70 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80104967:	8b 03                	mov    (%ebx),%eax
80104969:	83 c4 10             	add    $0x10,%esp
8010496c:	85 c0                	test   %eax,%eax
8010496e:	75 18                	jne    80104988 <holdingsleep+0x38>
  release(&lk->lk);
80104970:	83 ec 0c             	sub    $0xc,%esp
80104973:	56                   	push   %esi
80104974:	e8 97 01 00 00       	call   80104b10 <release>
  return r;
}
80104979:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010497c:	89 f8                	mov    %edi,%eax
8010497e:	5b                   	pop    %ebx
8010497f:	5e                   	pop    %esi
80104980:	5f                   	pop    %edi
80104981:	5d                   	pop    %ebp
80104982:	c3                   	ret    
80104983:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104987:	90                   	nop
  r = lk->locked && (lk->pid == myproc()->pid);
80104988:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
8010498b:	e8 20 f0 ff ff       	call   801039b0 <myproc>
80104990:	39 58 10             	cmp    %ebx,0x10(%eax)
80104993:	0f 94 c0             	sete   %al
80104996:	0f b6 c0             	movzbl %al,%eax
80104999:	89 c7                	mov    %eax,%edi
8010499b:	eb d3                	jmp    80104970 <holdingsleep+0x20>
8010499d:	66 90                	xchg   %ax,%ax
8010499f:	90                   	nop

801049a0 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
801049a0:	55                   	push   %ebp
801049a1:	89 e5                	mov    %esp,%ebp
801049a3:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
801049a6:	8b 55 0c             	mov    0xc(%ebp),%edx
  lk->locked = 0;
801049a9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->name = name;
801049af:	89 50 04             	mov    %edx,0x4(%eax)
  lk->cpu = 0;
801049b2:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801049b9:	5d                   	pop    %ebp
801049ba:	c3                   	ret    
801049bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801049bf:	90                   	nop

801049c0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
801049c0:	55                   	push   %ebp
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801049c1:	31 d2                	xor    %edx,%edx
{
801049c3:	89 e5                	mov    %esp,%ebp
801049c5:	53                   	push   %ebx
  ebp = (uint*)v - 2;
801049c6:	8b 45 08             	mov    0x8(%ebp),%eax
{
801049c9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  ebp = (uint*)v - 2;
801049cc:	83 e8 08             	sub    $0x8,%eax
  for(i = 0; i < 10; i++){
801049cf:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
801049d0:	8d 98 00 00 00 80    	lea    -0x80000000(%eax),%ebx
801049d6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
801049dc:	77 1a                	ja     801049f8 <getcallerpcs+0x38>
      break;
    pcs[i] = ebp[1];     // saved %eip
801049de:	8b 58 04             	mov    0x4(%eax),%ebx
801049e1:	89 1c 91             	mov    %ebx,(%ecx,%edx,4)
  for(i = 0; i < 10; i++){
801049e4:	83 c2 01             	add    $0x1,%edx
    ebp = (uint*)ebp[0]; // saved %ebp
801049e7:	8b 00                	mov    (%eax),%eax
  for(i = 0; i < 10; i++){
801049e9:	83 fa 0a             	cmp    $0xa,%edx
801049ec:	75 e2                	jne    801049d0 <getcallerpcs+0x10>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
}
801049ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801049f1:	c9                   	leave  
801049f2:	c3                   	ret    
801049f3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801049f7:	90                   	nop
  for(; i < 10; i++)
801049f8:	8d 04 91             	lea    (%ecx,%edx,4),%eax
801049fb:	8d 51 28             	lea    0x28(%ecx),%edx
801049fe:	66 90                	xchg   %ax,%ax
    pcs[i] = 0;
80104a00:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104a06:	83 c0 04             	add    $0x4,%eax
80104a09:	39 d0                	cmp    %edx,%eax
80104a0b:	75 f3                	jne    80104a00 <getcallerpcs+0x40>
}
80104a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a10:	c9                   	leave  
80104a11:	c3                   	ret    
80104a12:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104a20 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80104a20:	55                   	push   %ebp
80104a21:	89 e5                	mov    %esp,%ebp
80104a23:	53                   	push   %ebx
80104a24:	83 ec 04             	sub    $0x4,%esp
80104a27:	9c                   	pushf  
80104a28:	5b                   	pop    %ebx
  asm volatile("cli");
80104a29:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80104a2a:	e8 01 ef ff ff       	call   80103930 <mycpu>
80104a2f:	8b 80 a4 00 00 00    	mov    0xa4(%eax),%eax
80104a35:	85 c0                	test   %eax,%eax
80104a37:	74 17                	je     80104a50 <pushcli+0x30>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80104a39:	e8 f2 ee ff ff       	call   80103930 <mycpu>
80104a3e:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80104a45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104a48:	c9                   	leave  
80104a49:	c3                   	ret    
80104a4a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    mycpu()->intena = eflags & FL_IF;
80104a50:	e8 db ee ff ff       	call   80103930 <mycpu>
80104a55:	81 e3 00 02 00 00    	and    $0x200,%ebx
80104a5b:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80104a61:	eb d6                	jmp    80104a39 <pushcli+0x19>
80104a63:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104a6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104a70 <popcli>:

void
popcli(void)
{
80104a70:	55                   	push   %ebp
80104a71:	89 e5                	mov    %esp,%ebp
80104a73:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104a76:	9c                   	pushf  
80104a77:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80104a78:	f6 c4 02             	test   $0x2,%ah
80104a7b:	75 35                	jne    80104ab2 <popcli+0x42>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80104a7d:	e8 ae ee ff ff       	call   80103930 <mycpu>
80104a82:	83 a8 a4 00 00 00 01 	subl   $0x1,0xa4(%eax)
80104a89:	78 34                	js     80104abf <popcli+0x4f>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104a8b:	e8 a0 ee ff ff       	call   80103930 <mycpu>
80104a90:	8b 90 a4 00 00 00    	mov    0xa4(%eax),%edx
80104a96:	85 d2                	test   %edx,%edx
80104a98:	74 06                	je     80104aa0 <popcli+0x30>
    sti();
}
80104a9a:	c9                   	leave  
80104a9b:	c3                   	ret    
80104a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  if(mycpu()->ncli == 0 && mycpu()->intena)
80104aa0:	e8 8b ee ff ff       	call   80103930 <mycpu>
80104aa5:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80104aab:	85 c0                	test   %eax,%eax
80104aad:	74 eb                	je     80104a9a <popcli+0x2a>
  asm volatile("sti");
80104aaf:	fb                   	sti    
}
80104ab0:	c9                   	leave  
80104ab1:	c3                   	ret    
    panic("popcli - interruptible");
80104ab2:	83 ec 0c             	sub    $0xc,%esp
80104ab5:	68 0f 82 10 80       	push   $0x8010820f
80104aba:	e8 c1 b8 ff ff       	call   80100380 <panic>
    panic("popcli");
80104abf:	83 ec 0c             	sub    $0xc,%esp
80104ac2:	68 26 82 10 80       	push   $0x80108226
80104ac7:	e8 b4 b8 ff ff       	call   80100380 <panic>
80104acc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80104ad0 <holding>:
{
80104ad0:	55                   	push   %ebp
80104ad1:	89 e5                	mov    %esp,%ebp
80104ad3:	56                   	push   %esi
80104ad4:	53                   	push   %ebx
80104ad5:	8b 75 08             	mov    0x8(%ebp),%esi
80104ad8:	31 db                	xor    %ebx,%ebx
  pushcli();
80104ada:	e8 41 ff ff ff       	call   80104a20 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104adf:	8b 06                	mov    (%esi),%eax
80104ae1:	85 c0                	test   %eax,%eax
80104ae3:	75 0b                	jne    80104af0 <holding+0x20>
  popcli();
80104ae5:	e8 86 ff ff ff       	call   80104a70 <popcli>
}
80104aea:	89 d8                	mov    %ebx,%eax
80104aec:	5b                   	pop    %ebx
80104aed:	5e                   	pop    %esi
80104aee:	5d                   	pop    %ebp
80104aef:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80104af0:	8b 5e 08             	mov    0x8(%esi),%ebx
80104af3:	e8 38 ee ff ff       	call   80103930 <mycpu>
80104af8:	39 c3                	cmp    %eax,%ebx
80104afa:	0f 94 c3             	sete   %bl
  popcli();
80104afd:	e8 6e ff ff ff       	call   80104a70 <popcli>
  r = lock->locked && lock->cpu == mycpu();
80104b02:	0f b6 db             	movzbl %bl,%ebx
}
80104b05:	89 d8                	mov    %ebx,%eax
80104b07:	5b                   	pop    %ebx
80104b08:	5e                   	pop    %esi
80104b09:	5d                   	pop    %ebp
80104b0a:	c3                   	ret    
80104b0b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104b0f:	90                   	nop

80104b10 <release>:
{
80104b10:	55                   	push   %ebp
80104b11:	89 e5                	mov    %esp,%ebp
80104b13:	56                   	push   %esi
80104b14:	53                   	push   %ebx
80104b15:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80104b18:	e8 03 ff ff ff       	call   80104a20 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104b1d:	8b 03                	mov    (%ebx),%eax
80104b1f:	85 c0                	test   %eax,%eax
80104b21:	75 15                	jne    80104b38 <release+0x28>
  popcli();
80104b23:	e8 48 ff ff ff       	call   80104a70 <popcli>
    panic("release");
80104b28:	83 ec 0c             	sub    $0xc,%esp
80104b2b:	68 2d 82 10 80       	push   $0x8010822d
80104b30:	e8 4b b8 ff ff       	call   80100380 <panic>
80104b35:	8d 76 00             	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104b38:	8b 73 08             	mov    0x8(%ebx),%esi
80104b3b:	e8 f0 ed ff ff       	call   80103930 <mycpu>
80104b40:	39 c6                	cmp    %eax,%esi
80104b42:	75 df                	jne    80104b23 <release+0x13>
  popcli();
80104b44:	e8 27 ff ff ff       	call   80104a70 <popcli>
  lk->pcs[0] = 0;
80104b49:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80104b50:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80104b57:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80104b5c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
}
80104b62:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b65:	5b                   	pop    %ebx
80104b66:	5e                   	pop    %esi
80104b67:	5d                   	pop    %ebp
  popcli();
80104b68:	e9 03 ff ff ff       	jmp    80104a70 <popcli>
80104b6d:	8d 76 00             	lea    0x0(%esi),%esi

80104b70 <acquire>:
{
80104b70:	55                   	push   %ebp
80104b71:	89 e5                	mov    %esp,%ebp
80104b73:	53                   	push   %ebx
80104b74:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80104b77:	e8 a4 fe ff ff       	call   80104a20 <pushcli>
  if(holding(lk))
80104b7c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80104b7f:	e8 9c fe ff ff       	call   80104a20 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80104b84:	8b 03                	mov    (%ebx),%eax
80104b86:	85 c0                	test   %eax,%eax
80104b88:	75 7e                	jne    80104c08 <acquire+0x98>
  popcli();
80104b8a:	e8 e1 fe ff ff       	call   80104a70 <popcli>
  asm volatile("lock; xchgl %0, %1" :
80104b8f:	b9 01 00 00 00       	mov    $0x1,%ecx
80104b94:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  while(xchg(&lk->locked, 1) != 0)
80104b98:	8b 55 08             	mov    0x8(%ebp),%edx
80104b9b:	89 c8                	mov    %ecx,%eax
80104b9d:	f0 87 02             	lock xchg %eax,(%edx)
80104ba0:	85 c0                	test   %eax,%eax
80104ba2:	75 f4                	jne    80104b98 <acquire+0x28>
  __sync_synchronize();
80104ba4:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80104ba9:	8b 5d 08             	mov    0x8(%ebp),%ebx
80104bac:	e8 7f ed ff ff       	call   80103930 <mycpu>
  getcallerpcs(&lk, lk->pcs);
80104bb1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ebp = (uint*)v - 2;
80104bb4:	89 ea                	mov    %ebp,%edx
  lk->cpu = mycpu();
80104bb6:	89 43 08             	mov    %eax,0x8(%ebx)
  for(i = 0; i < 10; i++){
80104bb9:	31 c0                	xor    %eax,%eax
80104bbb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104bbf:	90                   	nop
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80104bc0:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80104bc6:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80104bcc:	77 1a                	ja     80104be8 <acquire+0x78>
    pcs[i] = ebp[1];     // saved %eip
80104bce:	8b 5a 04             	mov    0x4(%edx),%ebx
80104bd1:	89 5c 81 0c          	mov    %ebx,0xc(%ecx,%eax,4)
  for(i = 0; i < 10; i++){
80104bd5:	83 c0 01             	add    $0x1,%eax
    ebp = (uint*)ebp[0]; // saved %ebp
80104bd8:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80104bda:	83 f8 0a             	cmp    $0xa,%eax
80104bdd:	75 e1                	jne    80104bc0 <acquire+0x50>
}
80104bdf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104be2:	c9                   	leave  
80104be3:	c3                   	ret    
80104be4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  for(; i < 10; i++)
80104be8:	8d 44 81 0c          	lea    0xc(%ecx,%eax,4),%eax
80104bec:	8d 51 34             	lea    0x34(%ecx),%edx
80104bef:	90                   	nop
    pcs[i] = 0;
80104bf0:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  for(; i < 10; i++)
80104bf6:	83 c0 04             	add    $0x4,%eax
80104bf9:	39 c2                	cmp    %eax,%edx
80104bfb:	75 f3                	jne    80104bf0 <acquire+0x80>
}
80104bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c00:	c9                   	leave  
80104c01:	c3                   	ret    
80104c02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  r = lock->locked && lock->cpu == mycpu();
80104c08:	8b 5b 08             	mov    0x8(%ebx),%ebx
80104c0b:	e8 20 ed ff ff       	call   80103930 <mycpu>
80104c10:	39 c3                	cmp    %eax,%ebx
80104c12:	0f 85 72 ff ff ff    	jne    80104b8a <acquire+0x1a>
  popcli();
80104c18:	e8 53 fe ff ff       	call   80104a70 <popcli>
    panic("acquire");
80104c1d:	83 ec 0c             	sub    $0xc,%esp
80104c20:	68 35 82 10 80       	push   $0x80108235
80104c25:	e8 56 b7 ff ff       	call   80100380 <panic>
80104c2a:	66 90                	xchg   %ax,%ax
80104c2c:	66 90                	xchg   %ax,%ax
80104c2e:	66 90                	xchg   %ax,%ax

80104c30 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80104c30:	55                   	push   %ebp
80104c31:	89 e5                	mov    %esp,%ebp
80104c33:	57                   	push   %edi
80104c34:	8b 55 08             	mov    0x8(%ebp),%edx
80104c37:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104c3a:	53                   	push   %ebx
80104c3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  if ((int)dst%4 == 0 && n%4 == 0){
80104c3e:	89 d7                	mov    %edx,%edi
80104c40:	09 cf                	or     %ecx,%edi
80104c42:	83 e7 03             	and    $0x3,%edi
80104c45:	75 29                	jne    80104c70 <memset+0x40>
    c &= 0xFF;
80104c47:	0f b6 f8             	movzbl %al,%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80104c4a:	c1 e0 18             	shl    $0x18,%eax
80104c4d:	89 fb                	mov    %edi,%ebx
80104c4f:	c1 e9 02             	shr    $0x2,%ecx
80104c52:	c1 e3 10             	shl    $0x10,%ebx
80104c55:	09 d8                	or     %ebx,%eax
80104c57:	09 f8                	or     %edi,%eax
80104c59:	c1 e7 08             	shl    $0x8,%edi
80104c5c:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80104c5e:	89 d7                	mov    %edx,%edi
80104c60:	fc                   	cld    
80104c61:	f3 ab                	rep stos %eax,%es:(%edi)
  } else
    stosb(dst, c, n);
  return dst;
}
80104c63:	5b                   	pop    %ebx
80104c64:	89 d0                	mov    %edx,%eax
80104c66:	5f                   	pop    %edi
80104c67:	5d                   	pop    %ebp
80104c68:	c3                   	ret    
80104c69:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  asm volatile("cld; rep stosb" :
80104c70:	89 d7                	mov    %edx,%edi
80104c72:	fc                   	cld    
80104c73:	f3 aa                	rep stos %al,%es:(%edi)
80104c75:	5b                   	pop    %ebx
80104c76:	89 d0                	mov    %edx,%eax
80104c78:	5f                   	pop    %edi
80104c79:	5d                   	pop    %ebp
80104c7a:	c3                   	ret    
80104c7b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104c7f:	90                   	nop

80104c80 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80104c80:	55                   	push   %ebp
80104c81:	89 e5                	mov    %esp,%ebp
80104c83:	56                   	push   %esi
80104c84:	8b 75 10             	mov    0x10(%ebp),%esi
80104c87:	8b 55 08             	mov    0x8(%ebp),%edx
80104c8a:	53                   	push   %ebx
80104c8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80104c8e:	85 f6                	test   %esi,%esi
80104c90:	74 2e                	je     80104cc0 <memcmp+0x40>
80104c92:	01 c6                	add    %eax,%esi
80104c94:	eb 14                	jmp    80104caa <memcmp+0x2a>
80104c96:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104c9d:	8d 76 00             	lea    0x0(%esi),%esi
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
80104ca0:	83 c0 01             	add    $0x1,%eax
80104ca3:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80104ca6:	39 f0                	cmp    %esi,%eax
80104ca8:	74 16                	je     80104cc0 <memcmp+0x40>
    if(*s1 != *s2)
80104caa:	0f b6 0a             	movzbl (%edx),%ecx
80104cad:	0f b6 18             	movzbl (%eax),%ebx
80104cb0:	38 d9                	cmp    %bl,%cl
80104cb2:	74 ec                	je     80104ca0 <memcmp+0x20>
      return *s1 - *s2;
80104cb4:	0f b6 c1             	movzbl %cl,%eax
80104cb7:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80104cb9:	5b                   	pop    %ebx
80104cba:	5e                   	pop    %esi
80104cbb:	5d                   	pop    %ebp
80104cbc:	c3                   	ret    
80104cbd:	8d 76 00             	lea    0x0(%esi),%esi
80104cc0:	5b                   	pop    %ebx
  return 0;
80104cc1:	31 c0                	xor    %eax,%eax
}
80104cc3:	5e                   	pop    %esi
80104cc4:	5d                   	pop    %ebp
80104cc5:	c3                   	ret    
80104cc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ccd:	8d 76 00             	lea    0x0(%esi),%esi

80104cd0 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80104cd0:	55                   	push   %ebp
80104cd1:	89 e5                	mov    %esp,%ebp
80104cd3:	57                   	push   %edi
80104cd4:	8b 55 08             	mov    0x8(%ebp),%edx
80104cd7:	8b 4d 10             	mov    0x10(%ebp),%ecx
80104cda:	56                   	push   %esi
80104cdb:	8b 75 0c             	mov    0xc(%ebp),%esi
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80104cde:	39 d6                	cmp    %edx,%esi
80104ce0:	73 26                	jae    80104d08 <memmove+0x38>
80104ce2:	8d 3c 0e             	lea    (%esi,%ecx,1),%edi
80104ce5:	39 fa                	cmp    %edi,%edx
80104ce7:	73 1f                	jae    80104d08 <memmove+0x38>
80104ce9:	8d 41 ff             	lea    -0x1(%ecx),%eax
    s += n;
    d += n;
    while(n-- > 0)
80104cec:	85 c9                	test   %ecx,%ecx
80104cee:	74 0c                	je     80104cfc <memmove+0x2c>
      *--d = *--s;
80104cf0:	0f b6 0c 06          	movzbl (%esi,%eax,1),%ecx
80104cf4:	88 0c 02             	mov    %cl,(%edx,%eax,1)
    while(n-- > 0)
80104cf7:	83 e8 01             	sub    $0x1,%eax
80104cfa:	73 f4                	jae    80104cf0 <memmove+0x20>
  } else
    while(n-- > 0)
      *d++ = *s++;

  return dst;
}
80104cfc:	5e                   	pop    %esi
80104cfd:	89 d0                	mov    %edx,%eax
80104cff:	5f                   	pop    %edi
80104d00:	5d                   	pop    %ebp
80104d01:	c3                   	ret    
80104d02:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    while(n-- > 0)
80104d08:	8d 04 0e             	lea    (%esi,%ecx,1),%eax
80104d0b:	89 d7                	mov    %edx,%edi
80104d0d:	85 c9                	test   %ecx,%ecx
80104d0f:	74 eb                	je     80104cfc <memmove+0x2c>
80104d11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      *d++ = *s++;
80104d18:	a4                   	movsb  %ds:(%esi),%es:(%edi)
    while(n-- > 0)
80104d19:	39 c6                	cmp    %eax,%esi
80104d1b:	75 fb                	jne    80104d18 <memmove+0x48>
}
80104d1d:	5e                   	pop    %esi
80104d1e:	89 d0                	mov    %edx,%eax
80104d20:	5f                   	pop    %edi
80104d21:	5d                   	pop    %ebp
80104d22:	c3                   	ret    
80104d23:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d2a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104d30 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
  return memmove(dst, src, n);
80104d30:	eb 9e                	jmp    80104cd0 <memmove>
80104d32:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104d40 <strncmp>:
}

int
strncmp(const char *p, const char *q, uint n)
{
80104d40:	55                   	push   %ebp
80104d41:	89 e5                	mov    %esp,%ebp
80104d43:	56                   	push   %esi
80104d44:	8b 75 10             	mov    0x10(%ebp),%esi
80104d47:	8b 4d 08             	mov    0x8(%ebp),%ecx
80104d4a:	53                   	push   %ebx
80104d4b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(n > 0 && *p && *p == *q)
80104d4e:	85 f6                	test   %esi,%esi
80104d50:	74 2e                	je     80104d80 <strncmp+0x40>
80104d52:	01 d6                	add    %edx,%esi
80104d54:	eb 18                	jmp    80104d6e <strncmp+0x2e>
80104d56:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d5d:	8d 76 00             	lea    0x0(%esi),%esi
80104d60:	38 d8                	cmp    %bl,%al
80104d62:	75 14                	jne    80104d78 <strncmp+0x38>
    n--, p++, q++;
80104d64:	83 c2 01             	add    $0x1,%edx
80104d67:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80104d6a:	39 f2                	cmp    %esi,%edx
80104d6c:	74 12                	je     80104d80 <strncmp+0x40>
80104d6e:	0f b6 01             	movzbl (%ecx),%eax
80104d71:	0f b6 1a             	movzbl (%edx),%ebx
80104d74:	84 c0                	test   %al,%al
80104d76:	75 e8                	jne    80104d60 <strncmp+0x20>
  if(n == 0)
    return 0;
  return (uchar)*p - (uchar)*q;
80104d78:	29 d8                	sub    %ebx,%eax
}
80104d7a:	5b                   	pop    %ebx
80104d7b:	5e                   	pop    %esi
80104d7c:	5d                   	pop    %ebp
80104d7d:	c3                   	ret    
80104d7e:	66 90                	xchg   %ax,%ax
80104d80:	5b                   	pop    %ebx
    return 0;
80104d81:	31 c0                	xor    %eax,%eax
}
80104d83:	5e                   	pop    %esi
80104d84:	5d                   	pop    %ebp
80104d85:	c3                   	ret    
80104d86:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104d8d:	8d 76 00             	lea    0x0(%esi),%esi

80104d90 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80104d90:	55                   	push   %ebp
80104d91:	89 e5                	mov    %esp,%ebp
80104d93:	57                   	push   %edi
80104d94:	56                   	push   %esi
80104d95:	8b 75 08             	mov    0x8(%ebp),%esi
80104d98:	53                   	push   %ebx
80104d99:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80104d9c:	89 f0                	mov    %esi,%eax
80104d9e:	eb 15                	jmp    80104db5 <strncpy+0x25>
80104da0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
80104da4:	8b 7d 0c             	mov    0xc(%ebp),%edi
80104da7:	83 c0 01             	add    $0x1,%eax
80104daa:	0f b6 57 ff          	movzbl -0x1(%edi),%edx
80104dae:	88 50 ff             	mov    %dl,-0x1(%eax)
80104db1:	84 d2                	test   %dl,%dl
80104db3:	74 09                	je     80104dbe <strncpy+0x2e>
80104db5:	89 cb                	mov    %ecx,%ebx
80104db7:	83 e9 01             	sub    $0x1,%ecx
80104dba:	85 db                	test   %ebx,%ebx
80104dbc:	7f e2                	jg     80104da0 <strncpy+0x10>
    ;
  while(n-- > 0)
80104dbe:	89 c2                	mov    %eax,%edx
80104dc0:	85 c9                	test   %ecx,%ecx
80104dc2:	7e 17                	jle    80104ddb <strncpy+0x4b>
80104dc4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    *s++ = 0;
80104dc8:	83 c2 01             	add    $0x1,%edx
80104dcb:	89 c1                	mov    %eax,%ecx
80104dcd:	c6 42 ff 00          	movb   $0x0,-0x1(%edx)
  while(n-- > 0)
80104dd1:	29 d1                	sub    %edx,%ecx
80104dd3:	8d 4c 0b ff          	lea    -0x1(%ebx,%ecx,1),%ecx
80104dd7:	85 c9                	test   %ecx,%ecx
80104dd9:	7f ed                	jg     80104dc8 <strncpy+0x38>
  return os;
}
80104ddb:	5b                   	pop    %ebx
80104ddc:	89 f0                	mov    %esi,%eax
80104dde:	5e                   	pop    %esi
80104ddf:	5f                   	pop    %edi
80104de0:	5d                   	pop    %ebp
80104de1:	c3                   	ret    
80104de2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80104df0 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104df0:	55                   	push   %ebp
80104df1:	89 e5                	mov    %esp,%ebp
80104df3:	56                   	push   %esi
80104df4:	8b 55 10             	mov    0x10(%ebp),%edx
80104df7:	8b 75 08             	mov    0x8(%ebp),%esi
80104dfa:	53                   	push   %ebx
80104dfb:	8b 45 0c             	mov    0xc(%ebp),%eax
  char *os;

  os = s;
  if(n <= 0)
80104dfe:	85 d2                	test   %edx,%edx
80104e00:	7e 25                	jle    80104e27 <safestrcpy+0x37>
80104e02:	8d 5c 10 ff          	lea    -0x1(%eax,%edx,1),%ebx
80104e06:	89 f2                	mov    %esi,%edx
80104e08:	eb 16                	jmp    80104e20 <safestrcpy+0x30>
80104e0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104e10:	0f b6 08             	movzbl (%eax),%ecx
80104e13:	83 c0 01             	add    $0x1,%eax
80104e16:	83 c2 01             	add    $0x1,%edx
80104e19:	88 4a ff             	mov    %cl,-0x1(%edx)
80104e1c:	84 c9                	test   %cl,%cl
80104e1e:	74 04                	je     80104e24 <safestrcpy+0x34>
80104e20:	39 d8                	cmp    %ebx,%eax
80104e22:	75 ec                	jne    80104e10 <safestrcpy+0x20>
    ;
  *s = 0;
80104e24:	c6 02 00             	movb   $0x0,(%edx)
  return os;
}
80104e27:	89 f0                	mov    %esi,%eax
80104e29:	5b                   	pop    %ebx
80104e2a:	5e                   	pop    %esi
80104e2b:	5d                   	pop    %ebp
80104e2c:	c3                   	ret    
80104e2d:	8d 76 00             	lea    0x0(%esi),%esi

80104e30 <strlen>:

int
strlen(const char *s)
{
80104e30:	55                   	push   %ebp
  int n;

  for(n = 0; s[n]; n++)
80104e31:	31 c0                	xor    %eax,%eax
{
80104e33:	89 e5                	mov    %esp,%ebp
80104e35:	8b 55 08             	mov    0x8(%ebp),%edx
  for(n = 0; s[n]; n++)
80104e38:	80 3a 00             	cmpb   $0x0,(%edx)
80104e3b:	74 0c                	je     80104e49 <strlen+0x19>
80104e3d:	8d 76 00             	lea    0x0(%esi),%esi
80104e40:	83 c0 01             	add    $0x1,%eax
80104e43:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104e47:	75 f7                	jne    80104e40 <strlen+0x10>
    ;
  return n;
}
80104e49:	5d                   	pop    %ebp
80104e4a:	c3                   	ret    

80104e4b <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80104e4b:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104e4f:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104e53:	55                   	push   %ebp
  pushl %ebx
80104e54:	53                   	push   %ebx
  pushl %esi
80104e55:	56                   	push   %esi
  pushl %edi
80104e56:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104e57:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80104e59:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80104e5b:	5f                   	pop    %edi
  popl %esi
80104e5c:	5e                   	pop    %esi
  popl %ebx
80104e5d:	5b                   	pop    %ebx
  popl %ebp
80104e5e:	5d                   	pop    %ebp
  ret
80104e5f:	c3                   	ret    

80104e60 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104e60:	55                   	push   %ebp
80104e61:	89 e5                	mov    %esp,%ebp
80104e63:	53                   	push   %ebx
80104e64:	83 ec 04             	sub    $0x4,%esp
80104e67:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80104e6a:	e8 41 eb ff ff       	call   801039b0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104e6f:	8b 00                	mov    (%eax),%eax
80104e71:	39 d8                	cmp    %ebx,%eax
80104e73:	76 1b                	jbe    80104e90 <fetchint+0x30>
80104e75:	8d 53 04             	lea    0x4(%ebx),%edx
80104e78:	39 d0                	cmp    %edx,%eax
80104e7a:	72 14                	jb     80104e90 <fetchint+0x30>
    return -1;
  *ip = *(int*)(addr);
80104e7c:	8b 45 0c             	mov    0xc(%ebp),%eax
80104e7f:	8b 13                	mov    (%ebx),%edx
80104e81:	89 10                	mov    %edx,(%eax)
  return 0;
80104e83:	31 c0                	xor    %eax,%eax
}
80104e85:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e88:	c9                   	leave  
80104e89:	c3                   	ret    
80104e8a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80104e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e95:	eb ee                	jmp    80104e85 <fetchint+0x25>
80104e97:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104e9e:	66 90                	xchg   %ax,%ax

80104ea0 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104ea0:	55                   	push   %ebp
80104ea1:	89 e5                	mov    %esp,%ebp
80104ea3:	53                   	push   %ebx
80104ea4:	83 ec 04             	sub    $0x4,%esp
80104ea7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104eaa:	e8 01 eb ff ff       	call   801039b0 <myproc>

  if(addr >= curproc->sz)
80104eaf:	39 18                	cmp    %ebx,(%eax)
80104eb1:	76 2d                	jbe    80104ee0 <fetchstr+0x40>
    return -1;
  *pp = (char*)addr;
80104eb3:	8b 55 0c             	mov    0xc(%ebp),%edx
80104eb6:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104eb8:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104eba:	39 d3                	cmp    %edx,%ebx
80104ebc:	73 22                	jae    80104ee0 <fetchstr+0x40>
80104ebe:	89 d8                	mov    %ebx,%eax
80104ec0:	eb 0d                	jmp    80104ecf <fetchstr+0x2f>
80104ec2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80104ec8:	83 c0 01             	add    $0x1,%eax
80104ecb:	39 c2                	cmp    %eax,%edx
80104ecd:	76 11                	jbe    80104ee0 <fetchstr+0x40>
    if(*s == 0)
80104ecf:	80 38 00             	cmpb   $0x0,(%eax)
80104ed2:	75 f4                	jne    80104ec8 <fetchstr+0x28>
      return s - *pp;
80104ed4:	29 d8                	sub    %ebx,%eax
  }
  return -1;
}
80104ed6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ed9:	c9                   	leave  
80104eda:	c3                   	ret    
80104edb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80104edf:	90                   	nop
80104ee0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return -1;
80104ee3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104ee8:	c9                   	leave  
80104ee9:	c3                   	ret    
80104eea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80104ef0 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104ef0:	55                   	push   %ebp
80104ef1:	89 e5                	mov    %esp,%ebp
80104ef3:	56                   	push   %esi
80104ef4:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104ef5:	e8 b6 ea ff ff       	call   801039b0 <myproc>
80104efa:	8b 55 08             	mov    0x8(%ebp),%edx
80104efd:	8b 40 18             	mov    0x18(%eax),%eax
80104f00:	8b 40 44             	mov    0x44(%eax),%eax
80104f03:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104f06:	e8 a5 ea ff ff       	call   801039b0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f0b:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104f0e:	8b 00                	mov    (%eax),%eax
80104f10:	39 c6                	cmp    %eax,%esi
80104f12:	73 1c                	jae    80104f30 <argint+0x40>
80104f14:	8d 53 08             	lea    0x8(%ebx),%edx
80104f17:	39 d0                	cmp    %edx,%eax
80104f19:	72 15                	jb     80104f30 <argint+0x40>
  *ip = *(int*)(addr);
80104f1b:	8b 45 0c             	mov    0xc(%ebp),%eax
80104f1e:	8b 53 04             	mov    0x4(%ebx),%edx
80104f21:	89 10                	mov    %edx,(%eax)
  return 0;
80104f23:	31 c0                	xor    %eax,%eax
}
80104f25:	5b                   	pop    %ebx
80104f26:	5e                   	pop    %esi
80104f27:	5d                   	pop    %ebp
80104f28:	c3                   	ret    
80104f29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80104f30:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f35:	eb ee                	jmp    80104f25 <argint+0x35>
80104f37:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104f3e:	66 90                	xchg   %ax,%ax

80104f40 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104f40:	55                   	push   %ebp
80104f41:	89 e5                	mov    %esp,%ebp
80104f43:	57                   	push   %edi
80104f44:	56                   	push   %esi
80104f45:	53                   	push   %ebx
80104f46:	83 ec 0c             	sub    $0xc,%esp
  int i;
  struct proc *curproc = myproc();
80104f49:	e8 62 ea ff ff       	call   801039b0 <myproc>
80104f4e:	89 c6                	mov    %eax,%esi
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f50:	e8 5b ea ff ff       	call   801039b0 <myproc>
80104f55:	8b 55 08             	mov    0x8(%ebp),%edx
80104f58:	8b 40 18             	mov    0x18(%eax),%eax
80104f5b:	8b 40 44             	mov    0x44(%eax),%eax
80104f5e:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104f61:	e8 4a ea ff ff       	call   801039b0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104f66:	8d 7b 04             	lea    0x4(%ebx),%edi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104f69:	8b 00                	mov    (%eax),%eax
80104f6b:	39 c7                	cmp    %eax,%edi
80104f6d:	73 31                	jae    80104fa0 <argptr+0x60>
80104f6f:	8d 4b 08             	lea    0x8(%ebx),%ecx
80104f72:	39 c8                	cmp    %ecx,%eax
80104f74:	72 2a                	jb     80104fa0 <argptr+0x60>
 
  if(argint(n, &i) < 0)
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104f76:	8b 55 10             	mov    0x10(%ebp),%edx
  *ip = *(int*)(addr);
80104f79:	8b 43 04             	mov    0x4(%ebx),%eax
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104f7c:	85 d2                	test   %edx,%edx
80104f7e:	78 20                	js     80104fa0 <argptr+0x60>
80104f80:	8b 16                	mov    (%esi),%edx
80104f82:	39 c2                	cmp    %eax,%edx
80104f84:	76 1a                	jbe    80104fa0 <argptr+0x60>
80104f86:	8b 5d 10             	mov    0x10(%ebp),%ebx
80104f89:	01 c3                	add    %eax,%ebx
80104f8b:	39 da                	cmp    %ebx,%edx
80104f8d:	72 11                	jb     80104fa0 <argptr+0x60>
    return -1;
  *pp = (char*)i;
80104f8f:	8b 55 0c             	mov    0xc(%ebp),%edx
80104f92:	89 02                	mov    %eax,(%edx)
  return 0;
80104f94:	31 c0                	xor    %eax,%eax
}
80104f96:	83 c4 0c             	add    $0xc,%esp
80104f99:	5b                   	pop    %ebx
80104f9a:	5e                   	pop    %esi
80104f9b:	5f                   	pop    %edi
80104f9c:	5d                   	pop    %ebp
80104f9d:	c3                   	ret    
80104f9e:	66 90                	xchg   %ax,%ax
    return -1;
80104fa0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fa5:	eb ef                	jmp    80104f96 <argptr+0x56>
80104fa7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104fae:	66 90                	xchg   %ax,%ax

80104fb0 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104fb0:	55                   	push   %ebp
80104fb1:	89 e5                	mov    %esp,%ebp
80104fb3:	56                   	push   %esi
80104fb4:	53                   	push   %ebx
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104fb5:	e8 f6 e9 ff ff       	call   801039b0 <myproc>
80104fba:	8b 55 08             	mov    0x8(%ebp),%edx
80104fbd:	8b 40 18             	mov    0x18(%eax),%eax
80104fc0:	8b 40 44             	mov    0x44(%eax),%eax
80104fc3:	8d 1c 90             	lea    (%eax,%edx,4),%ebx
  struct proc *curproc = myproc();
80104fc6:	e8 e5 e9 ff ff       	call   801039b0 <myproc>
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104fcb:	8d 73 04             	lea    0x4(%ebx),%esi
  if(addr >= curproc->sz || addr+4 > curproc->sz)
80104fce:	8b 00                	mov    (%eax),%eax
80104fd0:	39 c6                	cmp    %eax,%esi
80104fd2:	73 44                	jae    80105018 <argstr+0x68>
80104fd4:	8d 53 08             	lea    0x8(%ebx),%edx
80104fd7:	39 d0                	cmp    %edx,%eax
80104fd9:	72 3d                	jb     80105018 <argstr+0x68>
  *ip = *(int*)(addr);
80104fdb:	8b 5b 04             	mov    0x4(%ebx),%ebx
  struct proc *curproc = myproc();
80104fde:	e8 cd e9 ff ff       	call   801039b0 <myproc>
  if(addr >= curproc->sz)
80104fe3:	3b 18                	cmp    (%eax),%ebx
80104fe5:	73 31                	jae    80105018 <argstr+0x68>
  *pp = (char*)addr;
80104fe7:	8b 55 0c             	mov    0xc(%ebp),%edx
80104fea:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104fec:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104fee:	39 d3                	cmp    %edx,%ebx
80104ff0:	73 26                	jae    80105018 <argstr+0x68>
80104ff2:	89 d8                	mov    %ebx,%eax
80104ff4:	eb 11                	jmp    80105007 <argstr+0x57>
80104ff6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80104ffd:	8d 76 00             	lea    0x0(%esi),%esi
80105000:	83 c0 01             	add    $0x1,%eax
80105003:	39 c2                	cmp    %eax,%edx
80105005:	76 11                	jbe    80105018 <argstr+0x68>
    if(*s == 0)
80105007:	80 38 00             	cmpb   $0x0,(%eax)
8010500a:	75 f4                	jne    80105000 <argstr+0x50>
      return s - *pp;
8010500c:	29 d8                	sub    %ebx,%eax
  int addr;
  if(argint(n, &addr) < 0)
    return -1;
  return fetchstr(addr, pp);
}
8010500e:	5b                   	pop    %ebx
8010500f:	5e                   	pop    %esi
80105010:	5d                   	pop    %ebp
80105011:	c3                   	ret    
80105012:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105018:	5b                   	pop    %ebx
    return -1;
80105019:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010501e:	5e                   	pop    %esi
8010501f:	5d                   	pop    %ebp
80105020:	c3                   	ret    
80105021:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105028:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010502f:	90                   	nop

80105030 <syscall>:
[SYS_getwmapinfo] sys_getwmapinfo,
};

void
syscall(void)
{
80105030:	55                   	push   %ebp
80105031:	89 e5                	mov    %esp,%ebp
80105033:	53                   	push   %ebx
80105034:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80105037:	e8 74 e9 ff ff       	call   801039b0 <myproc>
8010503c:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
8010503e:	8b 40 18             	mov    0x18(%eax),%eax
80105041:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80105044:	8d 50 ff             	lea    -0x1(%eax),%edx
80105047:	83 fa 18             	cmp    $0x18,%edx
8010504a:	77 24                	ja     80105070 <syscall+0x40>
8010504c:	8b 14 85 60 82 10 80 	mov    -0x7fef7da0(,%eax,4),%edx
80105053:	85 d2                	test   %edx,%edx
80105055:	74 19                	je     80105070 <syscall+0x40>
    curproc->tf->eax = syscalls[num]();
80105057:	ff d2                	call   *%edx
80105059:	89 c2                	mov    %eax,%edx
8010505b:	8b 43 18             	mov    0x18(%ebx),%eax
8010505e:	89 50 1c             	mov    %edx,0x1c(%eax)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80105061:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105064:	c9                   	leave  
80105065:	c3                   	ret    
80105066:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010506d:	8d 76 00             	lea    0x0(%esi),%esi
    cprintf("%d %s: unknown sys call %d\n",
80105070:	50                   	push   %eax
            curproc->pid, curproc->name, num);
80105071:	8d 43 6c             	lea    0x6c(%ebx),%eax
    cprintf("%d %s: unknown sys call %d\n",
80105074:	50                   	push   %eax
80105075:	ff 73 10             	push   0x10(%ebx)
80105078:	68 3d 82 10 80       	push   $0x8010823d
8010507d:	e8 1e b6 ff ff       	call   801006a0 <cprintf>
    curproc->tf->eax = -1;
80105082:	8b 43 18             	mov    0x18(%ebx),%eax
80105085:	83 c4 10             	add    $0x10,%esp
80105088:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
}
8010508f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105092:	c9                   	leave  
80105093:	c3                   	ret    
80105094:	66 90                	xchg   %ax,%ax
80105096:	66 90                	xchg   %ax,%ax
80105098:	66 90                	xchg   %ax,%ax
8010509a:	66 90                	xchg   %ax,%ax
8010509c:	66 90                	xchg   %ax,%ax
8010509e:	66 90                	xchg   %ax,%ax

801050a0 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801050a0:	55                   	push   %ebp
801050a1:	89 e5                	mov    %esp,%ebp
801050a3:	57                   	push   %edi
801050a4:	56                   	push   %esi
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801050a5:	8d 7d da             	lea    -0x26(%ebp),%edi
{
801050a8:	53                   	push   %ebx
801050a9:	83 ec 34             	sub    $0x34,%esp
801050ac:	89 4d d0             	mov    %ecx,-0x30(%ebp)
801050af:	8b 4d 08             	mov    0x8(%ebp),%ecx
  if((dp = nameiparent(path, name)) == 0)
801050b2:	57                   	push   %edi
801050b3:	50                   	push   %eax
{
801050b4:	89 55 d4             	mov    %edx,-0x2c(%ebp)
801050b7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  if((dp = nameiparent(path, name)) == 0)
801050ba:	e8 11 d0 ff ff       	call   801020d0 <nameiparent>
801050bf:	83 c4 10             	add    $0x10,%esp
801050c2:	85 c0                	test   %eax,%eax
801050c4:	0f 84 46 01 00 00    	je     80105210 <create+0x170>
    return 0;
  ilock(dp);
801050ca:	83 ec 0c             	sub    $0xc,%esp
801050cd:	89 c3                	mov    %eax,%ebx
801050cf:	50                   	push   %eax
801050d0:	e8 bb c6 ff ff       	call   80101790 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
801050d5:	83 c4 0c             	add    $0xc,%esp
801050d8:	6a 00                	push   $0x0
801050da:	57                   	push   %edi
801050db:	53                   	push   %ebx
801050dc:	e8 0f cc ff ff       	call   80101cf0 <dirlookup>
801050e1:	83 c4 10             	add    $0x10,%esp
801050e4:	89 c6                	mov    %eax,%esi
801050e6:	85 c0                	test   %eax,%eax
801050e8:	74 56                	je     80105140 <create+0xa0>
    iunlockput(dp);
801050ea:	83 ec 0c             	sub    $0xc,%esp
801050ed:	53                   	push   %ebx
801050ee:	e8 2d c9 ff ff       	call   80101a20 <iunlockput>
    ilock(ip);
801050f3:	89 34 24             	mov    %esi,(%esp)
801050f6:	e8 95 c6 ff ff       	call   80101790 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801050fb:	83 c4 10             	add    $0x10,%esp
801050fe:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105103:	75 1b                	jne    80105120 <create+0x80>
80105105:	66 83 7e 50 02       	cmpw   $0x2,0x50(%esi)
8010510a:	75 14                	jne    80105120 <create+0x80>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
8010510c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010510f:	89 f0                	mov    %esi,%eax
80105111:	5b                   	pop    %ebx
80105112:	5e                   	pop    %esi
80105113:	5f                   	pop    %edi
80105114:	5d                   	pop    %ebp
80105115:	c3                   	ret    
80105116:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010511d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105120:	83 ec 0c             	sub    $0xc,%esp
80105123:	56                   	push   %esi
    return 0;
80105124:	31 f6                	xor    %esi,%esi
    iunlockput(ip);
80105126:	e8 f5 c8 ff ff       	call   80101a20 <iunlockput>
    return 0;
8010512b:	83 c4 10             	add    $0x10,%esp
}
8010512e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105131:	89 f0                	mov    %esi,%eax
80105133:	5b                   	pop    %ebx
80105134:	5e                   	pop    %esi
80105135:	5f                   	pop    %edi
80105136:	5d                   	pop    %ebp
80105137:	c3                   	ret    
80105138:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010513f:	90                   	nop
  if((ip = ialloc(dp->dev, type)) == 0)
80105140:	0f bf 45 d4          	movswl -0x2c(%ebp),%eax
80105144:	83 ec 08             	sub    $0x8,%esp
80105147:	50                   	push   %eax
80105148:	ff 33                	push   (%ebx)
8010514a:	e8 d1 c4 ff ff       	call   80101620 <ialloc>
8010514f:	83 c4 10             	add    $0x10,%esp
80105152:	89 c6                	mov    %eax,%esi
80105154:	85 c0                	test   %eax,%eax
80105156:	0f 84 cd 00 00 00    	je     80105229 <create+0x189>
  ilock(ip);
8010515c:	83 ec 0c             	sub    $0xc,%esp
8010515f:	50                   	push   %eax
80105160:	e8 2b c6 ff ff       	call   80101790 <ilock>
  ip->major = major;
80105165:	0f b7 45 d0          	movzwl -0x30(%ebp),%eax
80105169:	66 89 46 52          	mov    %ax,0x52(%esi)
  ip->minor = minor;
8010516d:	0f b7 45 cc          	movzwl -0x34(%ebp),%eax
80105171:	66 89 46 54          	mov    %ax,0x54(%esi)
  ip->nlink = 1;
80105175:	b8 01 00 00 00       	mov    $0x1,%eax
8010517a:	66 89 46 56          	mov    %ax,0x56(%esi)
  iupdate(ip);
8010517e:	89 34 24             	mov    %esi,(%esp)
80105181:	e8 5a c5 ff ff       	call   801016e0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80105186:	83 c4 10             	add    $0x10,%esp
80105189:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010518e:	74 30                	je     801051c0 <create+0x120>
  if(dirlink(dp, name, ip->inum) < 0)
80105190:	83 ec 04             	sub    $0x4,%esp
80105193:	ff 76 04             	push   0x4(%esi)
80105196:	57                   	push   %edi
80105197:	53                   	push   %ebx
80105198:	e8 53 ce ff ff       	call   80101ff0 <dirlink>
8010519d:	83 c4 10             	add    $0x10,%esp
801051a0:	85 c0                	test   %eax,%eax
801051a2:	78 78                	js     8010521c <create+0x17c>
  iunlockput(dp);
801051a4:	83 ec 0c             	sub    $0xc,%esp
801051a7:	53                   	push   %ebx
801051a8:	e8 73 c8 ff ff       	call   80101a20 <iunlockput>
  return ip;
801051ad:	83 c4 10             	add    $0x10,%esp
}
801051b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801051b3:	89 f0                	mov    %esi,%eax
801051b5:	5b                   	pop    %ebx
801051b6:	5e                   	pop    %esi
801051b7:	5f                   	pop    %edi
801051b8:	5d                   	pop    %ebp
801051b9:	c3                   	ret    
801051ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iupdate(dp);
801051c0:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink++;  // for ".."
801051c3:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
    iupdate(dp);
801051c8:	53                   	push   %ebx
801051c9:	e8 12 c5 ff ff       	call   801016e0 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801051ce:	83 c4 0c             	add    $0xc,%esp
801051d1:	ff 76 04             	push   0x4(%esi)
801051d4:	68 e4 82 10 80       	push   $0x801082e4
801051d9:	56                   	push   %esi
801051da:	e8 11 ce ff ff       	call   80101ff0 <dirlink>
801051df:	83 c4 10             	add    $0x10,%esp
801051e2:	85 c0                	test   %eax,%eax
801051e4:	78 18                	js     801051fe <create+0x15e>
801051e6:	83 ec 04             	sub    $0x4,%esp
801051e9:	ff 73 04             	push   0x4(%ebx)
801051ec:	68 e3 82 10 80       	push   $0x801082e3
801051f1:	56                   	push   %esi
801051f2:	e8 f9 cd ff ff       	call   80101ff0 <dirlink>
801051f7:	83 c4 10             	add    $0x10,%esp
801051fa:	85 c0                	test   %eax,%eax
801051fc:	79 92                	jns    80105190 <create+0xf0>
      panic("create dots");
801051fe:	83 ec 0c             	sub    $0xc,%esp
80105201:	68 d7 82 10 80       	push   $0x801082d7
80105206:	e8 75 b1 ff ff       	call   80100380 <panic>
8010520b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010520f:	90                   	nop
}
80105210:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80105213:	31 f6                	xor    %esi,%esi
}
80105215:	5b                   	pop    %ebx
80105216:	89 f0                	mov    %esi,%eax
80105218:	5e                   	pop    %esi
80105219:	5f                   	pop    %edi
8010521a:	5d                   	pop    %ebp
8010521b:	c3                   	ret    
    panic("create: dirlink");
8010521c:	83 ec 0c             	sub    $0xc,%esp
8010521f:	68 e6 82 10 80       	push   $0x801082e6
80105224:	e8 57 b1 ff ff       	call   80100380 <panic>
    panic("create: ialloc");
80105229:	83 ec 0c             	sub    $0xc,%esp
8010522c:	68 c8 82 10 80       	push   $0x801082c8
80105231:	e8 4a b1 ff ff       	call   80100380 <panic>
80105236:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010523d:	8d 76 00             	lea    0x0(%esi),%esi

80105240 <sys_dup>:
{
80105240:	55                   	push   %ebp
80105241:	89 e5                	mov    %esp,%ebp
80105243:	56                   	push   %esi
80105244:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105245:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105248:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010524b:	50                   	push   %eax
8010524c:	6a 00                	push   $0x0
8010524e:	e8 9d fc ff ff       	call   80104ef0 <argint>
80105253:	83 c4 10             	add    $0x10,%esp
80105256:	85 c0                	test   %eax,%eax
80105258:	78 36                	js     80105290 <sys_dup+0x50>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010525a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010525e:	77 30                	ja     80105290 <sys_dup+0x50>
80105260:	e8 4b e7 ff ff       	call   801039b0 <myproc>
80105265:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105268:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010526c:	85 f6                	test   %esi,%esi
8010526e:	74 20                	je     80105290 <sys_dup+0x50>
  struct proc *curproc = myproc();
80105270:	e8 3b e7 ff ff       	call   801039b0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105275:	31 db                	xor    %ebx,%ebx
80105277:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010527e:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105280:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80105284:	85 d2                	test   %edx,%edx
80105286:	74 18                	je     801052a0 <sys_dup+0x60>
  for(fd = 0; fd < NOFILE; fd++){
80105288:	83 c3 01             	add    $0x1,%ebx
8010528b:	83 fb 10             	cmp    $0x10,%ebx
8010528e:	75 f0                	jne    80105280 <sys_dup+0x40>
}
80105290:	8d 65 f8             	lea    -0x8(%ebp),%esp
    return -1;
80105293:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
}
80105298:	89 d8                	mov    %ebx,%eax
8010529a:	5b                   	pop    %ebx
8010529b:	5e                   	pop    %esi
8010529c:	5d                   	pop    %ebp
8010529d:	c3                   	ret    
8010529e:	66 90                	xchg   %ax,%ax
  filedup(f);
801052a0:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
801052a3:	89 74 98 28          	mov    %esi,0x28(%eax,%ebx,4)
  filedup(f);
801052a7:	56                   	push   %esi
801052a8:	e8 03 bc ff ff       	call   80100eb0 <filedup>
  return fd;
801052ad:	83 c4 10             	add    $0x10,%esp
}
801052b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052b3:	89 d8                	mov    %ebx,%eax
801052b5:	5b                   	pop    %ebx
801052b6:	5e                   	pop    %esi
801052b7:	5d                   	pop    %ebp
801052b8:	c3                   	ret    
801052b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801052c0 <sys_read>:
{
801052c0:	55                   	push   %ebp
801052c1:	89 e5                	mov    %esp,%ebp
801052c3:	56                   	push   %esi
801052c4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801052c5:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
801052c8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801052cb:	53                   	push   %ebx
801052cc:	6a 00                	push   $0x0
801052ce:	e8 1d fc ff ff       	call   80104ef0 <argint>
801052d3:	83 c4 10             	add    $0x10,%esp
801052d6:	85 c0                	test   %eax,%eax
801052d8:	78 5e                	js     80105338 <sys_read+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801052da:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801052de:	77 58                	ja     80105338 <sys_read+0x78>
801052e0:	e8 cb e6 ff ff       	call   801039b0 <myproc>
801052e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801052e8:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
801052ec:	85 f6                	test   %esi,%esi
801052ee:	74 48                	je     80105338 <sys_read+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801052f0:	83 ec 08             	sub    $0x8,%esp
801052f3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801052f6:	50                   	push   %eax
801052f7:	6a 02                	push   $0x2
801052f9:	e8 f2 fb ff ff       	call   80104ef0 <argint>
801052fe:	83 c4 10             	add    $0x10,%esp
80105301:	85 c0                	test   %eax,%eax
80105303:	78 33                	js     80105338 <sys_read+0x78>
80105305:	83 ec 04             	sub    $0x4,%esp
80105308:	ff 75 f0             	push   -0x10(%ebp)
8010530b:	53                   	push   %ebx
8010530c:	6a 01                	push   $0x1
8010530e:	e8 2d fc ff ff       	call   80104f40 <argptr>
80105313:	83 c4 10             	add    $0x10,%esp
80105316:	85 c0                	test   %eax,%eax
80105318:	78 1e                	js     80105338 <sys_read+0x78>
  return fileread(f, p, n);
8010531a:	83 ec 04             	sub    $0x4,%esp
8010531d:	ff 75 f0             	push   -0x10(%ebp)
80105320:	ff 75 f4             	push   -0xc(%ebp)
80105323:	56                   	push   %esi
80105324:	e8 07 bd ff ff       	call   80101030 <fileread>
80105329:	83 c4 10             	add    $0x10,%esp
}
8010532c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010532f:	5b                   	pop    %ebx
80105330:	5e                   	pop    %esi
80105331:	5d                   	pop    %ebp
80105332:	c3                   	ret    
80105333:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80105337:	90                   	nop
    return -1;
80105338:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010533d:	eb ed                	jmp    8010532c <sys_read+0x6c>
8010533f:	90                   	nop

80105340 <sys_write>:
{
80105340:	55                   	push   %ebp
80105341:	89 e5                	mov    %esp,%ebp
80105343:	56                   	push   %esi
80105344:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105345:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105348:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010534b:	53                   	push   %ebx
8010534c:	6a 00                	push   $0x0
8010534e:	e8 9d fb ff ff       	call   80104ef0 <argint>
80105353:	83 c4 10             	add    $0x10,%esp
80105356:	85 c0                	test   %eax,%eax
80105358:	78 5e                	js     801053b8 <sys_write+0x78>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010535a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010535e:	77 58                	ja     801053b8 <sys_write+0x78>
80105360:	e8 4b e6 ff ff       	call   801039b0 <myproc>
80105365:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105368:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010536c:	85 f6                	test   %esi,%esi
8010536e:	74 48                	je     801053b8 <sys_write+0x78>
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105370:	83 ec 08             	sub    $0x8,%esp
80105373:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105376:	50                   	push   %eax
80105377:	6a 02                	push   $0x2
80105379:	e8 72 fb ff ff       	call   80104ef0 <argint>
8010537e:	83 c4 10             	add    $0x10,%esp
80105381:	85 c0                	test   %eax,%eax
80105383:	78 33                	js     801053b8 <sys_write+0x78>
80105385:	83 ec 04             	sub    $0x4,%esp
80105388:	ff 75 f0             	push   -0x10(%ebp)
8010538b:	53                   	push   %ebx
8010538c:	6a 01                	push   $0x1
8010538e:	e8 ad fb ff ff       	call   80104f40 <argptr>
80105393:	83 c4 10             	add    $0x10,%esp
80105396:	85 c0                	test   %eax,%eax
80105398:	78 1e                	js     801053b8 <sys_write+0x78>
  return filewrite(f, p, n);
8010539a:	83 ec 04             	sub    $0x4,%esp
8010539d:	ff 75 f0             	push   -0x10(%ebp)
801053a0:	ff 75 f4             	push   -0xc(%ebp)
801053a3:	56                   	push   %esi
801053a4:	e8 17 bd ff ff       	call   801010c0 <filewrite>
801053a9:	83 c4 10             	add    $0x10,%esp
}
801053ac:	8d 65 f8             	lea    -0x8(%ebp),%esp
801053af:	5b                   	pop    %ebx
801053b0:	5e                   	pop    %esi
801053b1:	5d                   	pop    %ebp
801053b2:	c3                   	ret    
801053b3:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801053b7:	90                   	nop
    return -1;
801053b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801053bd:	eb ed                	jmp    801053ac <sys_write+0x6c>
801053bf:	90                   	nop

801053c0 <sys_close>:
{
801053c0:	55                   	push   %ebp
801053c1:	89 e5                	mov    %esp,%ebp
801053c3:	56                   	push   %esi
801053c4:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
801053c5:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
801053c8:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
801053cb:	50                   	push   %eax
801053cc:	6a 00                	push   $0x0
801053ce:	e8 1d fb ff ff       	call   80104ef0 <argint>
801053d3:	83 c4 10             	add    $0x10,%esp
801053d6:	85 c0                	test   %eax,%eax
801053d8:	78 3e                	js     80105418 <sys_close+0x58>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
801053da:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
801053de:	77 38                	ja     80105418 <sys_close+0x58>
801053e0:	e8 cb e5 ff ff       	call   801039b0 <myproc>
801053e5:	8b 55 f4             	mov    -0xc(%ebp),%edx
801053e8:	8d 5a 08             	lea    0x8(%edx),%ebx
801053eb:	8b 74 98 08          	mov    0x8(%eax,%ebx,4),%esi
801053ef:	85 f6                	test   %esi,%esi
801053f1:	74 25                	je     80105418 <sys_close+0x58>
  myproc()->ofile[fd] = 0;
801053f3:	e8 b8 e5 ff ff       	call   801039b0 <myproc>
  fileclose(f);
801053f8:	83 ec 0c             	sub    $0xc,%esp
  myproc()->ofile[fd] = 0;
801053fb:	c7 44 98 08 00 00 00 	movl   $0x0,0x8(%eax,%ebx,4)
80105402:	00 
  fileclose(f);
80105403:	56                   	push   %esi
80105404:	e8 f7 ba ff ff       	call   80100f00 <fileclose>
  return 0;
80105409:	83 c4 10             	add    $0x10,%esp
8010540c:	31 c0                	xor    %eax,%eax
}
8010540e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105411:	5b                   	pop    %ebx
80105412:	5e                   	pop    %esi
80105413:	5d                   	pop    %ebp
80105414:	c3                   	ret    
80105415:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80105418:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010541d:	eb ef                	jmp    8010540e <sys_close+0x4e>
8010541f:	90                   	nop

80105420 <sys_fstat>:
{
80105420:	55                   	push   %ebp
80105421:	89 e5                	mov    %esp,%ebp
80105423:	56                   	push   %esi
80105424:	53                   	push   %ebx
  if(argint(n, &fd) < 0)
80105425:	8d 5d f4             	lea    -0xc(%ebp),%ebx
{
80105428:	83 ec 18             	sub    $0x18,%esp
  if(argint(n, &fd) < 0)
8010542b:	53                   	push   %ebx
8010542c:	6a 00                	push   $0x0
8010542e:	e8 bd fa ff ff       	call   80104ef0 <argint>
80105433:	83 c4 10             	add    $0x10,%esp
80105436:	85 c0                	test   %eax,%eax
80105438:	78 46                	js     80105480 <sys_fstat+0x60>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010543a:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010543e:	77 40                	ja     80105480 <sys_fstat+0x60>
80105440:	e8 6b e5 ff ff       	call   801039b0 <myproc>
80105445:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105448:	8b 74 90 28          	mov    0x28(%eax,%edx,4),%esi
8010544c:	85 f6                	test   %esi,%esi
8010544e:	74 30                	je     80105480 <sys_fstat+0x60>
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105450:	83 ec 04             	sub    $0x4,%esp
80105453:	6a 14                	push   $0x14
80105455:	53                   	push   %ebx
80105456:	6a 01                	push   $0x1
80105458:	e8 e3 fa ff ff       	call   80104f40 <argptr>
8010545d:	83 c4 10             	add    $0x10,%esp
80105460:	85 c0                	test   %eax,%eax
80105462:	78 1c                	js     80105480 <sys_fstat+0x60>
  return filestat(f, st);
80105464:	83 ec 08             	sub    $0x8,%esp
80105467:	ff 75 f4             	push   -0xc(%ebp)
8010546a:	56                   	push   %esi
8010546b:	e8 70 bb ff ff       	call   80100fe0 <filestat>
80105470:	83 c4 10             	add    $0x10,%esp
}
80105473:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105476:	5b                   	pop    %ebx
80105477:	5e                   	pop    %esi
80105478:	5d                   	pop    %ebp
80105479:	c3                   	ret    
8010547a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    return -1;
80105480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105485:	eb ec                	jmp    80105473 <sys_fstat+0x53>
80105487:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010548e:	66 90                	xchg   %ax,%ax

80105490 <sys_link>:
{
80105490:	55                   	push   %ebp
80105491:	89 e5                	mov    %esp,%ebp
80105493:	57                   	push   %edi
80105494:	56                   	push   %esi
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105495:	8d 45 d4             	lea    -0x2c(%ebp),%eax
{
80105498:	53                   	push   %ebx
80105499:	83 ec 34             	sub    $0x34,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010549c:	50                   	push   %eax
8010549d:	6a 00                	push   $0x0
8010549f:	e8 0c fb ff ff       	call   80104fb0 <argstr>
801054a4:	83 c4 10             	add    $0x10,%esp
801054a7:	85 c0                	test   %eax,%eax
801054a9:	0f 88 fb 00 00 00    	js     801055aa <sys_link+0x11a>
801054af:	83 ec 08             	sub    $0x8,%esp
801054b2:	8d 45 d0             	lea    -0x30(%ebp),%eax
801054b5:	50                   	push   %eax
801054b6:	6a 01                	push   $0x1
801054b8:	e8 f3 fa ff ff       	call   80104fb0 <argstr>
801054bd:	83 c4 10             	add    $0x10,%esp
801054c0:	85 c0                	test   %eax,%eax
801054c2:	0f 88 e2 00 00 00    	js     801055aa <sys_link+0x11a>
  begin_op();
801054c8:	e8 a3 d8 ff ff       	call   80102d70 <begin_op>
  if((ip = namei(old)) == 0){
801054cd:	83 ec 0c             	sub    $0xc,%esp
801054d0:	ff 75 d4             	push   -0x2c(%ebp)
801054d3:	e8 d8 cb ff ff       	call   801020b0 <namei>
801054d8:	83 c4 10             	add    $0x10,%esp
801054db:	89 c3                	mov    %eax,%ebx
801054dd:	85 c0                	test   %eax,%eax
801054df:	0f 84 e4 00 00 00    	je     801055c9 <sys_link+0x139>
  ilock(ip);
801054e5:	83 ec 0c             	sub    $0xc,%esp
801054e8:	50                   	push   %eax
801054e9:	e8 a2 c2 ff ff       	call   80101790 <ilock>
  if(ip->type == T_DIR){
801054ee:	83 c4 10             	add    $0x10,%esp
801054f1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801054f6:	0f 84 b5 00 00 00    	je     801055b1 <sys_link+0x121>
  iupdate(ip);
801054fc:	83 ec 0c             	sub    $0xc,%esp
  ip->nlink++;
801054ff:	66 83 43 56 01       	addw   $0x1,0x56(%ebx)
  if((dp = nameiparent(new, name)) == 0)
80105504:	8d 7d da             	lea    -0x26(%ebp),%edi
  iupdate(ip);
80105507:	53                   	push   %ebx
80105508:	e8 d3 c1 ff ff       	call   801016e0 <iupdate>
  iunlock(ip);
8010550d:	89 1c 24             	mov    %ebx,(%esp)
80105510:	e8 5b c3 ff ff       	call   80101870 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80105515:	58                   	pop    %eax
80105516:	5a                   	pop    %edx
80105517:	57                   	push   %edi
80105518:	ff 75 d0             	push   -0x30(%ebp)
8010551b:	e8 b0 cb ff ff       	call   801020d0 <nameiparent>
80105520:	83 c4 10             	add    $0x10,%esp
80105523:	89 c6                	mov    %eax,%esi
80105525:	85 c0                	test   %eax,%eax
80105527:	74 5b                	je     80105584 <sys_link+0xf4>
  ilock(dp);
80105529:	83 ec 0c             	sub    $0xc,%esp
8010552c:	50                   	push   %eax
8010552d:	e8 5e c2 ff ff       	call   80101790 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105532:	8b 03                	mov    (%ebx),%eax
80105534:	83 c4 10             	add    $0x10,%esp
80105537:	39 06                	cmp    %eax,(%esi)
80105539:	75 3d                	jne    80105578 <sys_link+0xe8>
8010553b:	83 ec 04             	sub    $0x4,%esp
8010553e:	ff 73 04             	push   0x4(%ebx)
80105541:	57                   	push   %edi
80105542:	56                   	push   %esi
80105543:	e8 a8 ca ff ff       	call   80101ff0 <dirlink>
80105548:	83 c4 10             	add    $0x10,%esp
8010554b:	85 c0                	test   %eax,%eax
8010554d:	78 29                	js     80105578 <sys_link+0xe8>
  iunlockput(dp);
8010554f:	83 ec 0c             	sub    $0xc,%esp
80105552:	56                   	push   %esi
80105553:	e8 c8 c4 ff ff       	call   80101a20 <iunlockput>
  iput(ip);
80105558:	89 1c 24             	mov    %ebx,(%esp)
8010555b:	e8 60 c3 ff ff       	call   801018c0 <iput>
  end_op();
80105560:	e8 7b d8 ff ff       	call   80102de0 <end_op>
  return 0;
80105565:	83 c4 10             	add    $0x10,%esp
80105568:	31 c0                	xor    %eax,%eax
}
8010556a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010556d:	5b                   	pop    %ebx
8010556e:	5e                   	pop    %esi
8010556f:	5f                   	pop    %edi
80105570:	5d                   	pop    %ebp
80105571:	c3                   	ret    
80105572:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    iunlockput(dp);
80105578:	83 ec 0c             	sub    $0xc,%esp
8010557b:	56                   	push   %esi
8010557c:	e8 9f c4 ff ff       	call   80101a20 <iunlockput>
    goto bad;
80105581:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80105584:	83 ec 0c             	sub    $0xc,%esp
80105587:	53                   	push   %ebx
80105588:	e8 03 c2 ff ff       	call   80101790 <ilock>
  ip->nlink--;
8010558d:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
80105592:	89 1c 24             	mov    %ebx,(%esp)
80105595:	e8 46 c1 ff ff       	call   801016e0 <iupdate>
  iunlockput(ip);
8010559a:	89 1c 24             	mov    %ebx,(%esp)
8010559d:	e8 7e c4 ff ff       	call   80101a20 <iunlockput>
  end_op();
801055a2:	e8 39 d8 ff ff       	call   80102de0 <end_op>
  return -1;
801055a7:	83 c4 10             	add    $0x10,%esp
801055aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055af:	eb b9                	jmp    8010556a <sys_link+0xda>
    iunlockput(ip);
801055b1:	83 ec 0c             	sub    $0xc,%esp
801055b4:	53                   	push   %ebx
801055b5:	e8 66 c4 ff ff       	call   80101a20 <iunlockput>
    end_op();
801055ba:	e8 21 d8 ff ff       	call   80102de0 <end_op>
    return -1;
801055bf:	83 c4 10             	add    $0x10,%esp
801055c2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055c7:	eb a1                	jmp    8010556a <sys_link+0xda>
    end_op();
801055c9:	e8 12 d8 ff ff       	call   80102de0 <end_op>
    return -1;
801055ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801055d3:	eb 95                	jmp    8010556a <sys_link+0xda>
801055d5:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801055dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801055e0 <sys_unlink>:
{
801055e0:	55                   	push   %ebp
801055e1:	89 e5                	mov    %esp,%ebp
801055e3:	57                   	push   %edi
801055e4:	56                   	push   %esi
  if(argstr(0, &path) < 0)
801055e5:	8d 45 c0             	lea    -0x40(%ebp),%eax
{
801055e8:	53                   	push   %ebx
801055e9:	83 ec 54             	sub    $0x54,%esp
  if(argstr(0, &path) < 0)
801055ec:	50                   	push   %eax
801055ed:	6a 00                	push   $0x0
801055ef:	e8 bc f9 ff ff       	call   80104fb0 <argstr>
801055f4:	83 c4 10             	add    $0x10,%esp
801055f7:	85 c0                	test   %eax,%eax
801055f9:	0f 88 7a 01 00 00    	js     80105779 <sys_unlink+0x199>
  begin_op();
801055ff:	e8 6c d7 ff ff       	call   80102d70 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105604:	8d 5d ca             	lea    -0x36(%ebp),%ebx
80105607:	83 ec 08             	sub    $0x8,%esp
8010560a:	53                   	push   %ebx
8010560b:	ff 75 c0             	push   -0x40(%ebp)
8010560e:	e8 bd ca ff ff       	call   801020d0 <nameiparent>
80105613:	83 c4 10             	add    $0x10,%esp
80105616:	89 45 b4             	mov    %eax,-0x4c(%ebp)
80105619:	85 c0                	test   %eax,%eax
8010561b:	0f 84 62 01 00 00    	je     80105783 <sys_unlink+0x1a3>
  ilock(dp);
80105621:	8b 7d b4             	mov    -0x4c(%ebp),%edi
80105624:	83 ec 0c             	sub    $0xc,%esp
80105627:	57                   	push   %edi
80105628:	e8 63 c1 ff ff       	call   80101790 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
8010562d:	58                   	pop    %eax
8010562e:	5a                   	pop    %edx
8010562f:	68 e4 82 10 80       	push   $0x801082e4
80105634:	53                   	push   %ebx
80105635:	e8 96 c6 ff ff       	call   80101cd0 <namecmp>
8010563a:	83 c4 10             	add    $0x10,%esp
8010563d:	85 c0                	test   %eax,%eax
8010563f:	0f 84 fb 00 00 00    	je     80105740 <sys_unlink+0x160>
80105645:	83 ec 08             	sub    $0x8,%esp
80105648:	68 e3 82 10 80       	push   $0x801082e3
8010564d:	53                   	push   %ebx
8010564e:	e8 7d c6 ff ff       	call   80101cd0 <namecmp>
80105653:	83 c4 10             	add    $0x10,%esp
80105656:	85 c0                	test   %eax,%eax
80105658:	0f 84 e2 00 00 00    	je     80105740 <sys_unlink+0x160>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010565e:	83 ec 04             	sub    $0x4,%esp
80105661:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80105664:	50                   	push   %eax
80105665:	53                   	push   %ebx
80105666:	57                   	push   %edi
80105667:	e8 84 c6 ff ff       	call   80101cf0 <dirlookup>
8010566c:	83 c4 10             	add    $0x10,%esp
8010566f:	89 c3                	mov    %eax,%ebx
80105671:	85 c0                	test   %eax,%eax
80105673:	0f 84 c7 00 00 00    	je     80105740 <sys_unlink+0x160>
  ilock(ip);
80105679:	83 ec 0c             	sub    $0xc,%esp
8010567c:	50                   	push   %eax
8010567d:	e8 0e c1 ff ff       	call   80101790 <ilock>
  if(ip->nlink < 1)
80105682:	83 c4 10             	add    $0x10,%esp
80105685:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010568a:	0f 8e 1c 01 00 00    	jle    801057ac <sys_unlink+0x1cc>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105690:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105695:	8d 7d d8             	lea    -0x28(%ebp),%edi
80105698:	74 66                	je     80105700 <sys_unlink+0x120>
  memset(&de, 0, sizeof(de));
8010569a:	83 ec 04             	sub    $0x4,%esp
8010569d:	6a 10                	push   $0x10
8010569f:	6a 00                	push   $0x0
801056a1:	57                   	push   %edi
801056a2:	e8 89 f5 ff ff       	call   80104c30 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801056a7:	6a 10                	push   $0x10
801056a9:	ff 75 c4             	push   -0x3c(%ebp)
801056ac:	57                   	push   %edi
801056ad:	ff 75 b4             	push   -0x4c(%ebp)
801056b0:	e8 eb c4 ff ff       	call   80101ba0 <writei>
801056b5:	83 c4 20             	add    $0x20,%esp
801056b8:	83 f8 10             	cmp    $0x10,%eax
801056bb:	0f 85 de 00 00 00    	jne    8010579f <sys_unlink+0x1bf>
  if(ip->type == T_DIR){
801056c1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801056c6:	0f 84 94 00 00 00    	je     80105760 <sys_unlink+0x180>
  iunlockput(dp);
801056cc:	83 ec 0c             	sub    $0xc,%esp
801056cf:	ff 75 b4             	push   -0x4c(%ebp)
801056d2:	e8 49 c3 ff ff       	call   80101a20 <iunlockput>
  ip->nlink--;
801056d7:	66 83 6b 56 01       	subw   $0x1,0x56(%ebx)
  iupdate(ip);
801056dc:	89 1c 24             	mov    %ebx,(%esp)
801056df:	e8 fc bf ff ff       	call   801016e0 <iupdate>
  iunlockput(ip);
801056e4:	89 1c 24             	mov    %ebx,(%esp)
801056e7:	e8 34 c3 ff ff       	call   80101a20 <iunlockput>
  end_op();
801056ec:	e8 ef d6 ff ff       	call   80102de0 <end_op>
  return 0;
801056f1:	83 c4 10             	add    $0x10,%esp
801056f4:	31 c0                	xor    %eax,%eax
}
801056f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801056f9:	5b                   	pop    %ebx
801056fa:	5e                   	pop    %esi
801056fb:	5f                   	pop    %edi
801056fc:	5d                   	pop    %ebp
801056fd:	c3                   	ret    
801056fe:	66 90                	xchg   %ax,%ax
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105700:	83 7b 58 20          	cmpl   $0x20,0x58(%ebx)
80105704:	76 94                	jbe    8010569a <sys_unlink+0xba>
80105706:	be 20 00 00 00       	mov    $0x20,%esi
8010570b:	eb 0b                	jmp    80105718 <sys_unlink+0x138>
8010570d:	8d 76 00             	lea    0x0(%esi),%esi
80105710:	83 c6 10             	add    $0x10,%esi
80105713:	3b 73 58             	cmp    0x58(%ebx),%esi
80105716:	73 82                	jae    8010569a <sys_unlink+0xba>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105718:	6a 10                	push   $0x10
8010571a:	56                   	push   %esi
8010571b:	57                   	push   %edi
8010571c:	53                   	push   %ebx
8010571d:	e8 7e c3 ff ff       	call   80101aa0 <readi>
80105722:	83 c4 10             	add    $0x10,%esp
80105725:	83 f8 10             	cmp    $0x10,%eax
80105728:	75 68                	jne    80105792 <sys_unlink+0x1b2>
    if(de.inum != 0)
8010572a:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
8010572f:	74 df                	je     80105710 <sys_unlink+0x130>
    iunlockput(ip);
80105731:	83 ec 0c             	sub    $0xc,%esp
80105734:	53                   	push   %ebx
80105735:	e8 e6 c2 ff ff       	call   80101a20 <iunlockput>
    goto bad;
8010573a:	83 c4 10             	add    $0x10,%esp
8010573d:	8d 76 00             	lea    0x0(%esi),%esi
  iunlockput(dp);
80105740:	83 ec 0c             	sub    $0xc,%esp
80105743:	ff 75 b4             	push   -0x4c(%ebp)
80105746:	e8 d5 c2 ff ff       	call   80101a20 <iunlockput>
  end_op();
8010574b:	e8 90 d6 ff ff       	call   80102de0 <end_op>
  return -1;
80105750:	83 c4 10             	add    $0x10,%esp
80105753:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105758:	eb 9c                	jmp    801056f6 <sys_unlink+0x116>
8010575a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    dp->nlink--;
80105760:	8b 45 b4             	mov    -0x4c(%ebp),%eax
    iupdate(dp);
80105763:	83 ec 0c             	sub    $0xc,%esp
    dp->nlink--;
80105766:	66 83 68 56 01       	subw   $0x1,0x56(%eax)
    iupdate(dp);
8010576b:	50                   	push   %eax
8010576c:	e8 6f bf ff ff       	call   801016e0 <iupdate>
80105771:	83 c4 10             	add    $0x10,%esp
80105774:	e9 53 ff ff ff       	jmp    801056cc <sys_unlink+0xec>
    return -1;
80105779:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010577e:	e9 73 ff ff ff       	jmp    801056f6 <sys_unlink+0x116>
    end_op();
80105783:	e8 58 d6 ff ff       	call   80102de0 <end_op>
    return -1;
80105788:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010578d:	e9 64 ff ff ff       	jmp    801056f6 <sys_unlink+0x116>
      panic("isdirempty: readi");
80105792:	83 ec 0c             	sub    $0xc,%esp
80105795:	68 08 83 10 80       	push   $0x80108308
8010579a:	e8 e1 ab ff ff       	call   80100380 <panic>
    panic("unlink: writei");
8010579f:	83 ec 0c             	sub    $0xc,%esp
801057a2:	68 1a 83 10 80       	push   $0x8010831a
801057a7:	e8 d4 ab ff ff       	call   80100380 <panic>
    panic("unlink: nlink < 1");
801057ac:	83 ec 0c             	sub    $0xc,%esp
801057af:	68 f6 82 10 80       	push   $0x801082f6
801057b4:	e8 c7 ab ff ff       	call   80100380 <panic>
801057b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801057c0 <sys_open>:

int
sys_open(void)
{
801057c0:	55                   	push   %ebp
801057c1:	89 e5                	mov    %esp,%ebp
801057c3:	57                   	push   %edi
801057c4:	56                   	push   %esi
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057c5:	8d 45 e0             	lea    -0x20(%ebp),%eax
{
801057c8:	53                   	push   %ebx
801057c9:	83 ec 24             	sub    $0x24,%esp
  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801057cc:	50                   	push   %eax
801057cd:	6a 00                	push   $0x0
801057cf:	e8 dc f7 ff ff       	call   80104fb0 <argstr>
801057d4:	83 c4 10             	add    $0x10,%esp
801057d7:	85 c0                	test   %eax,%eax
801057d9:	0f 88 8e 00 00 00    	js     8010586d <sys_open+0xad>
801057df:	83 ec 08             	sub    $0x8,%esp
801057e2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801057e5:	50                   	push   %eax
801057e6:	6a 01                	push   $0x1
801057e8:	e8 03 f7 ff ff       	call   80104ef0 <argint>
801057ed:	83 c4 10             	add    $0x10,%esp
801057f0:	85 c0                	test   %eax,%eax
801057f2:	78 79                	js     8010586d <sys_open+0xad>
    return -1;

  begin_op();
801057f4:	e8 77 d5 ff ff       	call   80102d70 <begin_op>

  if(omode & O_CREATE){
801057f9:	f6 45 e5 02          	testb  $0x2,-0x1b(%ebp)
801057fd:	75 79                	jne    80105878 <sys_open+0xb8>
    if(ip == 0){
      end_op();
      return -1;
    }
  } else {
    if((ip = namei(path)) == 0){
801057ff:	83 ec 0c             	sub    $0xc,%esp
80105802:	ff 75 e0             	push   -0x20(%ebp)
80105805:	e8 a6 c8 ff ff       	call   801020b0 <namei>
8010580a:	83 c4 10             	add    $0x10,%esp
8010580d:	89 c6                	mov    %eax,%esi
8010580f:	85 c0                	test   %eax,%eax
80105811:	0f 84 7e 00 00 00    	je     80105895 <sys_open+0xd5>
      end_op();
      return -1;
    }
    ilock(ip);
80105817:	83 ec 0c             	sub    $0xc,%esp
8010581a:	50                   	push   %eax
8010581b:	e8 70 bf ff ff       	call   80101790 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80105820:	83 c4 10             	add    $0x10,%esp
80105823:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80105828:	0f 84 c2 00 00 00    	je     801058f0 <sys_open+0x130>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010582e:	e8 0d b6 ff ff       	call   80100e40 <filealloc>
80105833:	89 c7                	mov    %eax,%edi
80105835:	85 c0                	test   %eax,%eax
80105837:	74 23                	je     8010585c <sys_open+0x9c>
  struct proc *curproc = myproc();
80105839:	e8 72 e1 ff ff       	call   801039b0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
8010583e:	31 db                	xor    %ebx,%ebx
    if(curproc->ofile[fd] == 0){
80105840:	8b 54 98 28          	mov    0x28(%eax,%ebx,4),%edx
80105844:	85 d2                	test   %edx,%edx
80105846:	74 60                	je     801058a8 <sys_open+0xe8>
  for(fd = 0; fd < NOFILE; fd++){
80105848:	83 c3 01             	add    $0x1,%ebx
8010584b:	83 fb 10             	cmp    $0x10,%ebx
8010584e:	75 f0                	jne    80105840 <sys_open+0x80>
    if(f)
      fileclose(f);
80105850:	83 ec 0c             	sub    $0xc,%esp
80105853:	57                   	push   %edi
80105854:	e8 a7 b6 ff ff       	call   80100f00 <fileclose>
80105859:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010585c:	83 ec 0c             	sub    $0xc,%esp
8010585f:	56                   	push   %esi
80105860:	e8 bb c1 ff ff       	call   80101a20 <iunlockput>
    end_op();
80105865:	e8 76 d5 ff ff       	call   80102de0 <end_op>
    return -1;
8010586a:	83 c4 10             	add    $0x10,%esp
8010586d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105872:	eb 6d                	jmp    801058e1 <sys_open+0x121>
80105874:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ip = create(path, T_FILE, 0, 0);
80105878:	83 ec 0c             	sub    $0xc,%esp
8010587b:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010587e:	31 c9                	xor    %ecx,%ecx
80105880:	ba 02 00 00 00       	mov    $0x2,%edx
80105885:	6a 00                	push   $0x0
80105887:	e8 14 f8 ff ff       	call   801050a0 <create>
    if(ip == 0){
8010588c:	83 c4 10             	add    $0x10,%esp
    ip = create(path, T_FILE, 0, 0);
8010588f:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80105891:	85 c0                	test   %eax,%eax
80105893:	75 99                	jne    8010582e <sys_open+0x6e>
      end_op();
80105895:	e8 46 d5 ff ff       	call   80102de0 <end_op>
      return -1;
8010589a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010589f:	eb 40                	jmp    801058e1 <sys_open+0x121>
801058a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  }
  iunlock(ip);
801058a8:	83 ec 0c             	sub    $0xc,%esp
      curproc->ofile[fd] = f;
801058ab:	89 7c 98 28          	mov    %edi,0x28(%eax,%ebx,4)
  iunlock(ip);
801058af:	56                   	push   %esi
801058b0:	e8 bb bf ff ff       	call   80101870 <iunlock>
  end_op();
801058b5:	e8 26 d5 ff ff       	call   80102de0 <end_op>

  f->type = FD_INODE;
801058ba:	c7 07 02 00 00 00    	movl   $0x2,(%edi)
  f->ip = ip;
  f->off = 0;
  f->readable = !(omode & O_WRONLY);
801058c0:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058c3:	83 c4 10             	add    $0x10,%esp
  f->ip = ip;
801058c6:	89 77 10             	mov    %esi,0x10(%edi)
  f->readable = !(omode & O_WRONLY);
801058c9:	89 d0                	mov    %edx,%eax
  f->off = 0;
801058cb:	c7 47 14 00 00 00 00 	movl   $0x0,0x14(%edi)
  f->readable = !(omode & O_WRONLY);
801058d2:	f7 d0                	not    %eax
801058d4:	83 e0 01             	and    $0x1,%eax
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058d7:	83 e2 03             	and    $0x3,%edx
  f->readable = !(omode & O_WRONLY);
801058da:	88 47 08             	mov    %al,0x8(%edi)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801058dd:	0f 95 47 09          	setne  0x9(%edi)
  return fd;
}
801058e1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801058e4:	89 d8                	mov    %ebx,%eax
801058e6:	5b                   	pop    %ebx
801058e7:	5e                   	pop    %esi
801058e8:	5f                   	pop    %edi
801058e9:	5d                   	pop    %ebp
801058ea:	c3                   	ret    
801058eb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801058ef:	90                   	nop
    if(ip->type == T_DIR && omode != O_RDONLY){
801058f0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801058f3:	85 c9                	test   %ecx,%ecx
801058f5:	0f 84 33 ff ff ff    	je     8010582e <sys_open+0x6e>
801058fb:	e9 5c ff ff ff       	jmp    8010585c <sys_open+0x9c>

80105900 <sys_mkdir>:

int
sys_mkdir(void)
{
80105900:	55                   	push   %ebp
80105901:	89 e5                	mov    %esp,%ebp
80105903:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80105906:	e8 65 d4 ff ff       	call   80102d70 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010590b:	83 ec 08             	sub    $0x8,%esp
8010590e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105911:	50                   	push   %eax
80105912:	6a 00                	push   $0x0
80105914:	e8 97 f6 ff ff       	call   80104fb0 <argstr>
80105919:	83 c4 10             	add    $0x10,%esp
8010591c:	85 c0                	test   %eax,%eax
8010591e:	78 30                	js     80105950 <sys_mkdir+0x50>
80105920:	83 ec 0c             	sub    $0xc,%esp
80105923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105926:	31 c9                	xor    %ecx,%ecx
80105928:	ba 01 00 00 00       	mov    $0x1,%edx
8010592d:	6a 00                	push   $0x0
8010592f:	e8 6c f7 ff ff       	call   801050a0 <create>
80105934:	83 c4 10             	add    $0x10,%esp
80105937:	85 c0                	test   %eax,%eax
80105939:	74 15                	je     80105950 <sys_mkdir+0x50>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010593b:	83 ec 0c             	sub    $0xc,%esp
8010593e:	50                   	push   %eax
8010593f:	e8 dc c0 ff ff       	call   80101a20 <iunlockput>
  end_op();
80105944:	e8 97 d4 ff ff       	call   80102de0 <end_op>
  return 0;
80105949:	83 c4 10             	add    $0x10,%esp
8010594c:	31 c0                	xor    %eax,%eax
}
8010594e:	c9                   	leave  
8010594f:	c3                   	ret    
    end_op();
80105950:	e8 8b d4 ff ff       	call   80102de0 <end_op>
    return -1;
80105955:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010595a:	c9                   	leave  
8010595b:	c3                   	ret    
8010595c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105960 <sys_mknod>:

int
sys_mknod(void)
{
80105960:	55                   	push   %ebp
80105961:	89 e5                	mov    %esp,%ebp
80105963:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80105966:	e8 05 d4 ff ff       	call   80102d70 <begin_op>
  if((argstr(0, &path)) < 0 ||
8010596b:	83 ec 08             	sub    $0x8,%esp
8010596e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105971:	50                   	push   %eax
80105972:	6a 00                	push   $0x0
80105974:	e8 37 f6 ff ff       	call   80104fb0 <argstr>
80105979:	83 c4 10             	add    $0x10,%esp
8010597c:	85 c0                	test   %eax,%eax
8010597e:	78 60                	js     801059e0 <sys_mknod+0x80>
     argint(1, &major) < 0 ||
80105980:	83 ec 08             	sub    $0x8,%esp
80105983:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105986:	50                   	push   %eax
80105987:	6a 01                	push   $0x1
80105989:	e8 62 f5 ff ff       	call   80104ef0 <argint>
  if((argstr(0, &path)) < 0 ||
8010598e:	83 c4 10             	add    $0x10,%esp
80105991:	85 c0                	test   %eax,%eax
80105993:	78 4b                	js     801059e0 <sys_mknod+0x80>
     argint(2, &minor) < 0 ||
80105995:	83 ec 08             	sub    $0x8,%esp
80105998:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010599b:	50                   	push   %eax
8010599c:	6a 02                	push   $0x2
8010599e:	e8 4d f5 ff ff       	call   80104ef0 <argint>
     argint(1, &major) < 0 ||
801059a3:	83 c4 10             	add    $0x10,%esp
801059a6:	85 c0                	test   %eax,%eax
801059a8:	78 36                	js     801059e0 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
801059aa:	0f bf 45 f4          	movswl -0xc(%ebp),%eax
801059ae:	83 ec 0c             	sub    $0xc,%esp
801059b1:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
801059b5:	ba 03 00 00 00       	mov    $0x3,%edx
801059ba:	50                   	push   %eax
801059bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801059be:	e8 dd f6 ff ff       	call   801050a0 <create>
     argint(2, &minor) < 0 ||
801059c3:	83 c4 10             	add    $0x10,%esp
801059c6:	85 c0                	test   %eax,%eax
801059c8:	74 16                	je     801059e0 <sys_mknod+0x80>
    end_op();
    return -1;
  }
  iunlockput(ip);
801059ca:	83 ec 0c             	sub    $0xc,%esp
801059cd:	50                   	push   %eax
801059ce:	e8 4d c0 ff ff       	call   80101a20 <iunlockput>
  end_op();
801059d3:	e8 08 d4 ff ff       	call   80102de0 <end_op>
  return 0;
801059d8:	83 c4 10             	add    $0x10,%esp
801059db:	31 c0                	xor    %eax,%eax
}
801059dd:	c9                   	leave  
801059de:	c3                   	ret    
801059df:	90                   	nop
    end_op();
801059e0:	e8 fb d3 ff ff       	call   80102de0 <end_op>
    return -1;
801059e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801059ea:	c9                   	leave  
801059eb:	c3                   	ret    
801059ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

801059f0 <sys_chdir>:

int
sys_chdir(void)
{
801059f0:	55                   	push   %ebp
801059f1:	89 e5                	mov    %esp,%ebp
801059f3:	56                   	push   %esi
801059f4:	53                   	push   %ebx
801059f5:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
801059f8:	e8 b3 df ff ff       	call   801039b0 <myproc>
801059fd:	89 c6                	mov    %eax,%esi
  
  begin_op();
801059ff:	e8 6c d3 ff ff       	call   80102d70 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80105a04:	83 ec 08             	sub    $0x8,%esp
80105a07:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a0a:	50                   	push   %eax
80105a0b:	6a 00                	push   $0x0
80105a0d:	e8 9e f5 ff ff       	call   80104fb0 <argstr>
80105a12:	83 c4 10             	add    $0x10,%esp
80105a15:	85 c0                	test   %eax,%eax
80105a17:	78 77                	js     80105a90 <sys_chdir+0xa0>
80105a19:	83 ec 0c             	sub    $0xc,%esp
80105a1c:	ff 75 f4             	push   -0xc(%ebp)
80105a1f:	e8 8c c6 ff ff       	call   801020b0 <namei>
80105a24:	83 c4 10             	add    $0x10,%esp
80105a27:	89 c3                	mov    %eax,%ebx
80105a29:	85 c0                	test   %eax,%eax
80105a2b:	74 63                	je     80105a90 <sys_chdir+0xa0>
    end_op();
    return -1;
  }
  ilock(ip);
80105a2d:	83 ec 0c             	sub    $0xc,%esp
80105a30:	50                   	push   %eax
80105a31:	e8 5a bd ff ff       	call   80101790 <ilock>
  if(ip->type != T_DIR){
80105a36:	83 c4 10             	add    $0x10,%esp
80105a39:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80105a3e:	75 30                	jne    80105a70 <sys_chdir+0x80>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80105a40:	83 ec 0c             	sub    $0xc,%esp
80105a43:	53                   	push   %ebx
80105a44:	e8 27 be ff ff       	call   80101870 <iunlock>
  iput(curproc->cwd);
80105a49:	58                   	pop    %eax
80105a4a:	ff 76 68             	push   0x68(%esi)
80105a4d:	e8 6e be ff ff       	call   801018c0 <iput>
  end_op();
80105a52:	e8 89 d3 ff ff       	call   80102de0 <end_op>
  curproc->cwd = ip;
80105a57:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80105a5a:	83 c4 10             	add    $0x10,%esp
80105a5d:	31 c0                	xor    %eax,%eax
}
80105a5f:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105a62:	5b                   	pop    %ebx
80105a63:	5e                   	pop    %esi
80105a64:	5d                   	pop    %ebp
80105a65:	c3                   	ret    
80105a66:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a6d:	8d 76 00             	lea    0x0(%esi),%esi
    iunlockput(ip);
80105a70:	83 ec 0c             	sub    $0xc,%esp
80105a73:	53                   	push   %ebx
80105a74:	e8 a7 bf ff ff       	call   80101a20 <iunlockput>
    end_op();
80105a79:	e8 62 d3 ff ff       	call   80102de0 <end_op>
    return -1;
80105a7e:	83 c4 10             	add    $0x10,%esp
80105a81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a86:	eb d7                	jmp    80105a5f <sys_chdir+0x6f>
80105a88:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105a8f:	90                   	nop
    end_op();
80105a90:	e8 4b d3 ff ff       	call   80102de0 <end_op>
    return -1;
80105a95:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a9a:	eb c3                	jmp    80105a5f <sys_chdir+0x6f>
80105a9c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105aa0 <sys_exec>:

int
sys_exec(void)
{
80105aa0:	55                   	push   %ebp
80105aa1:	89 e5                	mov    %esp,%ebp
80105aa3:	57                   	push   %edi
80105aa4:	56                   	push   %esi
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105aa5:	8d 85 5c ff ff ff    	lea    -0xa4(%ebp),%eax
{
80105aab:	53                   	push   %ebx
80105aac:	81 ec a4 00 00 00    	sub    $0xa4,%esp
  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80105ab2:	50                   	push   %eax
80105ab3:	6a 00                	push   $0x0
80105ab5:	e8 f6 f4 ff ff       	call   80104fb0 <argstr>
80105aba:	83 c4 10             	add    $0x10,%esp
80105abd:	85 c0                	test   %eax,%eax
80105abf:	0f 88 87 00 00 00    	js     80105b4c <sys_exec+0xac>
80105ac5:	83 ec 08             	sub    $0x8,%esp
80105ac8:	8d 85 60 ff ff ff    	lea    -0xa0(%ebp),%eax
80105ace:	50                   	push   %eax
80105acf:	6a 01                	push   $0x1
80105ad1:	e8 1a f4 ff ff       	call   80104ef0 <argint>
80105ad6:	83 c4 10             	add    $0x10,%esp
80105ad9:	85 c0                	test   %eax,%eax
80105adb:	78 6f                	js     80105b4c <sys_exec+0xac>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80105add:	83 ec 04             	sub    $0x4,%esp
80105ae0:	8d b5 68 ff ff ff    	lea    -0x98(%ebp),%esi
  for(i=0;; i++){
80105ae6:	31 db                	xor    %ebx,%ebx
  memset(argv, 0, sizeof(argv));
80105ae8:	68 80 00 00 00       	push   $0x80
80105aed:	6a 00                	push   $0x0
80105aef:	56                   	push   %esi
80105af0:	e8 3b f1 ff ff       	call   80104c30 <memset>
80105af5:	83 c4 10             	add    $0x10,%esp
80105af8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105aff:	90                   	nop
    if(i >= NELEM(argv))
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80105b00:	83 ec 08             	sub    $0x8,%esp
80105b03:	8d 85 64 ff ff ff    	lea    -0x9c(%ebp),%eax
80105b09:	8d 3c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%edi
80105b10:	50                   	push   %eax
80105b11:	8b 85 60 ff ff ff    	mov    -0xa0(%ebp),%eax
80105b17:	01 f8                	add    %edi,%eax
80105b19:	50                   	push   %eax
80105b1a:	e8 41 f3 ff ff       	call   80104e60 <fetchint>
80105b1f:	83 c4 10             	add    $0x10,%esp
80105b22:	85 c0                	test   %eax,%eax
80105b24:	78 26                	js     80105b4c <sys_exec+0xac>
      return -1;
    if(uarg == 0){
80105b26:	8b 85 64 ff ff ff    	mov    -0x9c(%ebp),%eax
80105b2c:	85 c0                	test   %eax,%eax
80105b2e:	74 30                	je     80105b60 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80105b30:	83 ec 08             	sub    $0x8,%esp
80105b33:	8d 14 3e             	lea    (%esi,%edi,1),%edx
80105b36:	52                   	push   %edx
80105b37:	50                   	push   %eax
80105b38:	e8 63 f3 ff ff       	call   80104ea0 <fetchstr>
80105b3d:	83 c4 10             	add    $0x10,%esp
80105b40:	85 c0                	test   %eax,%eax
80105b42:	78 08                	js     80105b4c <sys_exec+0xac>
  for(i=0;; i++){
80105b44:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80105b47:	83 fb 20             	cmp    $0x20,%ebx
80105b4a:	75 b4                	jne    80105b00 <sys_exec+0x60>
      return -1;
  }
  return exec(path, argv);
}
80105b4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return -1;
80105b4f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105b54:	5b                   	pop    %ebx
80105b55:	5e                   	pop    %esi
80105b56:	5f                   	pop    %edi
80105b57:	5d                   	pop    %ebp
80105b58:	c3                   	ret    
80105b59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      argv[i] = 0;
80105b60:	c7 84 9d 68 ff ff ff 	movl   $0x0,-0x98(%ebp,%ebx,4)
80105b67:	00 00 00 00 
  return exec(path, argv);
80105b6b:	83 ec 08             	sub    $0x8,%esp
80105b6e:	56                   	push   %esi
80105b6f:	ff b5 5c ff ff ff    	push   -0xa4(%ebp)
80105b75:	e8 36 af ff ff       	call   80100ab0 <exec>
80105b7a:	83 c4 10             	add    $0x10,%esp
}
80105b7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105b80:	5b                   	pop    %ebx
80105b81:	5e                   	pop    %esi
80105b82:	5f                   	pop    %edi
80105b83:	5d                   	pop    %ebp
80105b84:	c3                   	ret    
80105b85:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105b8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105b90 <sys_pipe>:

int
sys_pipe(void)
{
80105b90:	55                   	push   %ebp
80105b91:	89 e5                	mov    %esp,%ebp
80105b93:	57                   	push   %edi
80105b94:	56                   	push   %esi
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105b95:	8d 45 dc             	lea    -0x24(%ebp),%eax
{
80105b98:	53                   	push   %ebx
80105b99:	83 ec 20             	sub    $0x20,%esp
  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80105b9c:	6a 08                	push   $0x8
80105b9e:	50                   	push   %eax
80105b9f:	6a 00                	push   $0x0
80105ba1:	e8 9a f3 ff ff       	call   80104f40 <argptr>
80105ba6:	83 c4 10             	add    $0x10,%esp
80105ba9:	85 c0                	test   %eax,%eax
80105bab:	78 4a                	js     80105bf7 <sys_pipe+0x67>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80105bad:	83 ec 08             	sub    $0x8,%esp
80105bb0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105bb3:	50                   	push   %eax
80105bb4:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105bb7:	50                   	push   %eax
80105bb8:	e8 83 d8 ff ff       	call   80103440 <pipealloc>
80105bbd:	83 c4 10             	add    $0x10,%esp
80105bc0:	85 c0                	test   %eax,%eax
80105bc2:	78 33                	js     80105bf7 <sys_pipe+0x67>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105bc4:	8b 7d e0             	mov    -0x20(%ebp),%edi
  for(fd = 0; fd < NOFILE; fd++){
80105bc7:	31 db                	xor    %ebx,%ebx
  struct proc *curproc = myproc();
80105bc9:	e8 e2 dd ff ff       	call   801039b0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105bce:	66 90                	xchg   %ax,%ax
    if(curproc->ofile[fd] == 0){
80105bd0:	8b 74 98 28          	mov    0x28(%eax,%ebx,4),%esi
80105bd4:	85 f6                	test   %esi,%esi
80105bd6:	74 28                	je     80105c00 <sys_pipe+0x70>
  for(fd = 0; fd < NOFILE; fd++){
80105bd8:	83 c3 01             	add    $0x1,%ebx
80105bdb:	83 fb 10             	cmp    $0x10,%ebx
80105bde:	75 f0                	jne    80105bd0 <sys_pipe+0x40>
    if(fd0 >= 0)
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
80105be0:	83 ec 0c             	sub    $0xc,%esp
80105be3:	ff 75 e0             	push   -0x20(%ebp)
80105be6:	e8 15 b3 ff ff       	call   80100f00 <fileclose>
    fileclose(wf);
80105beb:	58                   	pop    %eax
80105bec:	ff 75 e4             	push   -0x1c(%ebp)
80105bef:	e8 0c b3 ff ff       	call   80100f00 <fileclose>
    return -1;
80105bf4:	83 c4 10             	add    $0x10,%esp
80105bf7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105bfc:	eb 53                	jmp    80105c51 <sys_pipe+0xc1>
80105bfe:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105c00:	8d 73 08             	lea    0x8(%ebx),%esi
80105c03:	89 7c b0 08          	mov    %edi,0x8(%eax,%esi,4)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80105c07:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  struct proc *curproc = myproc();
80105c0a:	e8 a1 dd ff ff       	call   801039b0 <myproc>
  for(fd = 0; fd < NOFILE; fd++){
80105c0f:	31 d2                	xor    %edx,%edx
80105c11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    if(curproc->ofile[fd] == 0){
80105c18:	8b 4c 90 28          	mov    0x28(%eax,%edx,4),%ecx
80105c1c:	85 c9                	test   %ecx,%ecx
80105c1e:	74 20                	je     80105c40 <sys_pipe+0xb0>
  for(fd = 0; fd < NOFILE; fd++){
80105c20:	83 c2 01             	add    $0x1,%edx
80105c23:	83 fa 10             	cmp    $0x10,%edx
80105c26:	75 f0                	jne    80105c18 <sys_pipe+0x88>
      myproc()->ofile[fd0] = 0;
80105c28:	e8 83 dd ff ff       	call   801039b0 <myproc>
80105c2d:	c7 44 b0 08 00 00 00 	movl   $0x0,0x8(%eax,%esi,4)
80105c34:	00 
80105c35:	eb a9                	jmp    80105be0 <sys_pipe+0x50>
80105c37:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c3e:	66 90                	xchg   %ax,%ax
      curproc->ofile[fd] = f;
80105c40:	89 7c 90 28          	mov    %edi,0x28(%eax,%edx,4)
  }
  fd[0] = fd0;
80105c44:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c47:	89 18                	mov    %ebx,(%eax)
  fd[1] = fd1;
80105c49:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105c4c:	89 50 04             	mov    %edx,0x4(%eax)
  return 0;
80105c4f:	31 c0                	xor    %eax,%eax
}
80105c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c54:	5b                   	pop    %ebx
80105c55:	5e                   	pop    %esi
80105c56:	5f                   	pop    %edi
80105c57:	5d                   	pop    %ebp
80105c58:	c3                   	ret    
80105c59:	66 90                	xchg   %ax,%ax
80105c5b:	66 90                	xchg   %ax,%ax
80105c5d:	66 90                	xchg   %ax,%ax
80105c5f:	90                   	nop

80105c60 <sys_fork>:
#include "proc.h"

int
sys_fork(void)
{
  return fork();
80105c60:	e9 eb de ff ff       	jmp    80103b50 <fork>
80105c65:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105c70 <sys_exit>:
}

int
sys_exit(void)
{
80105c70:	55                   	push   %ebp
80105c71:	89 e5                	mov    %esp,%ebp
80105c73:	83 ec 08             	sub    $0x8,%esp
  exit();
80105c76:	e8 95 e1 ff ff       	call   80103e10 <exit>
  return 0;  // not reached
}
80105c7b:	31 c0                	xor    %eax,%eax
80105c7d:	c9                   	leave  
80105c7e:	c3                   	ret    
80105c7f:	90                   	nop

80105c80 <sys_wait>:

int
sys_wait(void)
{
  return wait();
80105c80:	e9 bb e2 ff ff       	jmp    80103f40 <wait>
80105c85:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105c8c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi

80105c90 <sys_kill>:
}

int
sys_kill(void)
{
80105c90:	55                   	push   %ebp
80105c91:	89 e5                	mov    %esp,%ebp
80105c93:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80105c96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105c99:	50                   	push   %eax
80105c9a:	6a 00                	push   $0x0
80105c9c:	e8 4f f2 ff ff       	call   80104ef0 <argint>
80105ca1:	83 c4 10             	add    $0x10,%esp
80105ca4:	85 c0                	test   %eax,%eax
80105ca6:	78 18                	js     80105cc0 <sys_kill+0x30>
    return -1;
  return kill(pid);
80105ca8:	83 ec 0c             	sub    $0xc,%esp
80105cab:	ff 75 f4             	push   -0xc(%ebp)
80105cae:	e8 2d e5 ff ff       	call   801041e0 <kill>
80105cb3:	83 c4 10             	add    $0x10,%esp
}
80105cb6:	c9                   	leave  
80105cb7:	c3                   	ret    
80105cb8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cbf:	90                   	nop
80105cc0:	c9                   	leave  
    return -1;
80105cc1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105cc6:	c3                   	ret    
80105cc7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105cce:	66 90                	xchg   %ax,%ax

80105cd0 <sys_getpid>:

int
sys_getpid(void)
{
80105cd0:	55                   	push   %ebp
80105cd1:	89 e5                	mov    %esp,%ebp
80105cd3:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80105cd6:	e8 d5 dc ff ff       	call   801039b0 <myproc>
80105cdb:	8b 40 10             	mov    0x10(%eax),%eax
}
80105cde:	c9                   	leave  
80105cdf:	c3                   	ret    

80105ce0 <sys_sbrk>:

int
sys_sbrk(void)
{
80105ce0:	55                   	push   %ebp
80105ce1:	89 e5                	mov    %esp,%ebp
80105ce3:	53                   	push   %ebx
  int addr;
  int n;

  if(argint(0, &n) < 0)
80105ce4:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105ce7:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105cea:	50                   	push   %eax
80105ceb:	6a 00                	push   $0x0
80105ced:	e8 fe f1 ff ff       	call   80104ef0 <argint>
80105cf2:	83 c4 10             	add    $0x10,%esp
80105cf5:	85 c0                	test   %eax,%eax
80105cf7:	78 27                	js     80105d20 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80105cf9:	e8 b2 dc ff ff       	call   801039b0 <myproc>
  if(growproc(n) < 0)
80105cfe:	83 ec 0c             	sub    $0xc,%esp
  addr = myproc()->sz;
80105d01:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80105d03:	ff 75 f4             	push   -0xc(%ebp)
80105d06:	e8 c5 dd ff ff       	call   80103ad0 <growproc>
80105d0b:	83 c4 10             	add    $0x10,%esp
80105d0e:	85 c0                	test   %eax,%eax
80105d10:	78 0e                	js     80105d20 <sys_sbrk+0x40>
    return -1;
  return addr;
}
80105d12:	89 d8                	mov    %ebx,%eax
80105d14:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105d17:	c9                   	leave  
80105d18:	c3                   	ret    
80105d19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return -1;
80105d20:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80105d25:	eb eb                	jmp    80105d12 <sys_sbrk+0x32>
80105d27:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105d2e:	66 90                	xchg   %ax,%ax

80105d30 <sys_sleep>:

int
sys_sleep(void)
{
80105d30:	55                   	push   %ebp
80105d31:	89 e5                	mov    %esp,%ebp
80105d33:	53                   	push   %ebx
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80105d34:	8d 45 f4             	lea    -0xc(%ebp),%eax
{
80105d37:	83 ec 1c             	sub    $0x1c,%esp
  if(argint(0, &n) < 0)
80105d3a:	50                   	push   %eax
80105d3b:	6a 00                	push   $0x0
80105d3d:	e8 ae f1 ff ff       	call   80104ef0 <argint>
80105d42:	83 c4 10             	add    $0x10,%esp
80105d45:	85 c0                	test   %eax,%eax
80105d47:	0f 88 8a 00 00 00    	js     80105dd7 <sys_sleep+0xa7>
    return -1;
  acquire(&tickslock);
80105d4d:	83 ec 0c             	sub    $0xc,%esp
80105d50:	68 80 9d 11 80       	push   $0x80119d80
80105d55:	e8 16 ee ff ff       	call   80104b70 <acquire>
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80105d5a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  ticks0 = ticks;
80105d5d:	8b 1d 60 9d 11 80    	mov    0x80119d60,%ebx
  while(ticks - ticks0 < n){
80105d63:	83 c4 10             	add    $0x10,%esp
80105d66:	85 d2                	test   %edx,%edx
80105d68:	75 27                	jne    80105d91 <sys_sleep+0x61>
80105d6a:	eb 54                	jmp    80105dc0 <sys_sleep+0x90>
80105d6c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80105d70:	83 ec 08             	sub    $0x8,%esp
80105d73:	68 80 9d 11 80       	push   $0x80119d80
80105d78:	68 60 9d 11 80       	push   $0x80119d60
80105d7d:	e8 3e e3 ff ff       	call   801040c0 <sleep>
  while(ticks - ticks0 < n){
80105d82:	a1 60 9d 11 80       	mov    0x80119d60,%eax
80105d87:	83 c4 10             	add    $0x10,%esp
80105d8a:	29 d8                	sub    %ebx,%eax
80105d8c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80105d8f:	73 2f                	jae    80105dc0 <sys_sleep+0x90>
    if(myproc()->killed){
80105d91:	e8 1a dc ff ff       	call   801039b0 <myproc>
80105d96:	8b 40 24             	mov    0x24(%eax),%eax
80105d99:	85 c0                	test   %eax,%eax
80105d9b:	74 d3                	je     80105d70 <sys_sleep+0x40>
      release(&tickslock);
80105d9d:	83 ec 0c             	sub    $0xc,%esp
80105da0:	68 80 9d 11 80       	push   $0x80119d80
80105da5:	e8 66 ed ff ff       	call   80104b10 <release>
  }
  release(&tickslock);
  return 0;
}
80105daa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
      return -1;
80105dad:	83 c4 10             	add    $0x10,%esp
80105db0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105db5:	c9                   	leave  
80105db6:	c3                   	ret    
80105db7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105dbe:	66 90                	xchg   %ax,%ax
  release(&tickslock);
80105dc0:	83 ec 0c             	sub    $0xc,%esp
80105dc3:	68 80 9d 11 80       	push   $0x80119d80
80105dc8:	e8 43 ed ff ff       	call   80104b10 <release>
  return 0;
80105dcd:	83 c4 10             	add    $0x10,%esp
80105dd0:	31 c0                	xor    %eax,%eax
}
80105dd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105dd5:	c9                   	leave  
80105dd6:	c3                   	ret    
    return -1;
80105dd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ddc:	eb f4                	jmp    80105dd2 <sys_sleep+0xa2>
80105dde:	66 90                	xchg   %ax,%ax

80105de0 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80105de0:	55                   	push   %ebp
80105de1:	89 e5                	mov    %esp,%ebp
80105de3:	53                   	push   %ebx
80105de4:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80105de7:	68 80 9d 11 80       	push   $0x80119d80
80105dec:	e8 7f ed ff ff       	call   80104b70 <acquire>
  xticks = ticks;
80105df1:	8b 1d 60 9d 11 80    	mov    0x80119d60,%ebx
  release(&tickslock);
80105df7:	c7 04 24 80 9d 11 80 	movl   $0x80119d80,(%esp)
80105dfe:	e8 0d ed ff ff       	call   80104b10 <release>
  return xticks;
}
80105e03:	89 d8                	mov    %ebx,%eax
80105e05:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105e08:	c9                   	leave  
80105e09:	c3                   	ret    
80105e0a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80105e10 <sys_wmap>:
// 
// Returns: 
//  Success: the starting virtual address of the memory
//  Fail: FAILED
int 
sys_wmap(void){
80105e10:	55                   	push   %ebp
80105e11:	89 e5                	mov    %esp,%ebp
80105e13:	83 ec 20             	sub    $0x20,%esp
  int fd; // the kind of memory mapping you're requesting for, ignored if MAP_ANONYMOUS flag set

  ////////////////
  // Get inputs //
  ////////////////
  if (argint(0, (int*)&addr) < 0){
80105e16:	8d 45 e8             	lea    -0x18(%ebp),%eax
80105e19:	50                   	push   %eax
80105e1a:	6a 00                	push   $0x0
80105e1c:	e8 cf f0 ff ff       	call   80104ef0 <argint>
80105e21:	83 c4 10             	add    $0x10,%esp
80105e24:	85 c0                	test   %eax,%eax
80105e26:	78 58                	js     80105e80 <sys_wmap+0x70>
    // Failed to retrieve addr
    return FAILED;
  }
  if (argint(1, &length) < 0){
80105e28:	83 ec 08             	sub    $0x8,%esp
80105e2b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105e2e:	50                   	push   %eax
80105e2f:	6a 01                	push   $0x1
80105e31:	e8 ba f0 ff ff       	call   80104ef0 <argint>
80105e36:	83 c4 10             	add    $0x10,%esp
80105e39:	85 c0                	test   %eax,%eax
80105e3b:	78 43                	js     80105e80 <sys_wmap+0x70>
    // Failed to retrieve length
    return FAILED;
  }
  if (argint(2, &flags) < 0){
80105e3d:	83 ec 08             	sub    $0x8,%esp
80105e40:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105e43:	50                   	push   %eax
80105e44:	6a 02                	push   $0x2
80105e46:	e8 a5 f0 ff ff       	call   80104ef0 <argint>
80105e4b:	83 c4 10             	add    $0x10,%esp
80105e4e:	85 c0                	test   %eax,%eax
80105e50:	78 2e                	js     80105e80 <sys_wmap+0x70>
    // Failed to retrieve flags
    return FAILED;
  }
  if (argint(3, &fd) < 0){
80105e52:	83 ec 08             	sub    $0x8,%esp
80105e55:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e58:	50                   	push   %eax
80105e59:	6a 03                	push   $0x3
80105e5b:	e8 90 f0 ff ff       	call   80104ef0 <argint>
80105e60:	83 c4 10             	add    $0x10,%esp
80105e63:	85 c0                	test   %eax,%eax
80105e65:	78 19                	js     80105e80 <sys_wmap+0x70>
    return FAILED;
  }

  // Success: return the starting virtual address of the memory on success
  // Fail: return FAILED
  return wmap_helper(addr, length, flags, fd);
80105e67:	ff 75 f4             	push   -0xc(%ebp)
80105e6a:	ff 75 f0             	push   -0x10(%ebp)
80105e6d:	ff 75 ec             	push   -0x14(%ebp)
80105e70:	ff 75 e8             	push   -0x18(%ebp)
80105e73:	e8 a8 e4 ff ff       	call   80104320 <wmap_helper>
80105e78:	83 c4 10             	add    $0x10,%esp
}
80105e7b:	c9                   	leave  
80105e7c:	c3                   	ret    
80105e7d:	8d 76 00             	lea    0x0(%esi),%esi
80105e80:	c9                   	leave  
    return FAILED;
80105e81:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105e86:	c3                   	ret    
80105e87:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105e8e:	66 90                	xchg   %ax,%ax

80105e90 <sys_wunmap>:
//
// Returns:
//  Success: SUCCESS
//  Fail: FAILED
int 
sys_wunmap(void){
80105e90:	55                   	push   %ebp
80105e91:	89 e5                	mov    %esp,%ebp
80105e93:	83 ec 20             	sub    $0x20,%esp
  uint addr;

  ///////////////
  // Get input //
  ///////////////
  if (argint(0, (int*)&addr) < 0){
80105e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105e99:	50                   	push   %eax
80105e9a:	6a 00                	push   $0x0
80105e9c:	e8 4f f0 ff ff       	call   80104ef0 <argint>
80105ea1:	83 c4 10             	add    $0x10,%esp
80105ea4:	85 c0                	test   %eax,%eax
80105ea6:	78 18                	js     80105ec0 <sys_wunmap+0x30>
    // Failed to retrieve addr
    return FAILED;
  }
  
  return wunmap_helper(addr);
80105ea8:	83 ec 0c             	sub    $0xc,%esp
80105eab:	ff 75 f4             	push   -0xc(%ebp)
80105eae:	e8 5d e6 ff ff       	call   80104510 <wunmap_helper>
80105eb3:	83 c4 10             	add    $0x10,%esp
}
80105eb6:	c9                   	leave  
80105eb7:	c3                   	ret    
80105eb8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105ebf:	90                   	nop
80105ec0:	c9                   	leave  
    return FAILED;
80105ec1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ec6:	c3                   	ret    
80105ec7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105ece:	66 90                	xchg   %ax,%ax

80105ed0 <sys_va2pa>:
//
// Returns:
//  Success: the physical address on success
//  Fail: -1
uint 
sys_va2pa(void){
80105ed0:	55                   	push   %ebp
80105ed1:	89 e5                	mov    %esp,%ebp
80105ed3:	53                   	push   %ebx
  uint pa;

  ///////////////
  // Get input //
  ///////////////
  if (argint(0, (int*)&va) < 0){
80105ed4:	8d 45 f4             	lea    -0xc(%ebp),%eax
sys_va2pa(void){
80105ed7:	83 ec 1c             	sub    $0x1c,%esp
  if (argint(0, (int*)&va) < 0){
80105eda:	50                   	push   %eax
80105edb:	6a 00                	push   $0x0
80105edd:	e8 0e f0 ff ff       	call   80104ef0 <argint>
80105ee2:	83 c4 10             	add    $0x10,%esp
80105ee5:	85 c0                	test   %eax,%eax
80105ee7:	78 3f                	js     80105f28 <sys_va2pa+0x58>
    // Failed to retrieve addr
    return FAILED;
  }

  // get PTE for virtual address
  pte = walkpgdir(myproc()->pgdir, (void *)va, 0);
80105ee9:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80105eec:	e8 bf da ff ff       	call   801039b0 <myproc>
80105ef1:	83 ec 04             	sub    $0x4,%esp
80105ef4:	6a 00                	push   $0x0
80105ef6:	53                   	push   %ebx
80105ef7:	ff 70 04             	push   0x4(%eax)
80105efa:	e8 61 13 00 00       	call   80107260 <walkpgdir>
  if (pte == 0 || !(*pte & PTE_P)) {
80105eff:	83 c4 10             	add    $0x10,%esp
80105f02:	85 c0                	test   %eax,%eax
80105f04:	74 22                	je     80105f28 <sys_va2pa+0x58>
80105f06:	8b 10                	mov    (%eax),%edx
80105f08:	f6 c2 01             	test   $0x1,%dl
80105f0b:	74 1b                	je     80105f28 <sys_va2pa+0x58>
      return -1;  // invalid translation or not present
  }
  // get physical address from PTE
  pa = PTE_ADDR(*pte) | (va & 0xFFF); // page base addr with offset
80105f0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105f10:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx

  return pa;
}
80105f16:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105f19:	c9                   	leave  
  pa = PTE_ADDR(*pte) | (va & 0xFFF); // page base addr with offset
80105f1a:	25 ff 0f 00 00       	and    $0xfff,%eax
80105f1f:	09 d0                	or     %edx,%eax
}
80105f21:	c3                   	ret    
80105f22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80105f28:	8b 5d fc             	mov    -0x4(%ebp),%ebx
    return FAILED;
80105f2b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105f30:	c9                   	leave  
80105f31:	c3                   	ret    
80105f32:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105f39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80105f40 <sys_getwmapinfo>:
//
// Returns:
//  Success: SUCCESS
//  Fail: FAILED
int 
sys_getwmapinfo(){
80105f40:	55                   	push   %ebp
80105f41:	89 e5                	mov    %esp,%ebp
80105f43:	53                   	push   %ebx
  struct wmapinfo *wminfo;
  ///////////////
  // Get input //
  ///////////////
  if (argptr(0, (char **)&wminfo, sizeof(*wminfo)) < 0) {
80105f44:	8d 45 f4             	lea    -0xc(%ebp),%eax
sys_getwmapinfo(){
80105f47:	83 ec 18             	sub    $0x18,%esp
  if (argptr(0, (char **)&wminfo, sizeof(*wminfo)) < 0) {
80105f4a:	68 c4 00 00 00       	push   $0xc4
80105f4f:	50                   	push   %eax
80105f50:	6a 00                	push   $0x0
80105f52:	e8 e9 ef ff ff       	call   80104f40 <argptr>
80105f57:	83 c4 10             	add    $0x10,%esp
80105f5a:	85 c0                	test   %eax,%eax
80105f5c:	78 32                	js     80105f90 <sys_getwmapinfo+0x50>
    // Failed to retrieve the pointer to wmapinfo
    return FAILED;
  }

  // initialize wmapinfo struct
  memset(wminfo, 0, sizeof(struct wmapinfo));
80105f5e:	83 ec 04             	sub    $0x4,%esp
80105f61:	68 c4 00 00 00       	push   $0xc4
80105f66:	6a 00                	push   $0x0
80105f68:	ff 75 f4             	push   -0xc(%ebp)
80105f6b:	e8 c0 ec ff ff       	call   80104c30 <memset>

  return getwmapinfo_helper(myproc(), wminfo);
80105f70:	8b 5d f4             	mov    -0xc(%ebp),%ebx
80105f73:	e8 38 da ff ff       	call   801039b0 <myproc>
80105f78:	5a                   	pop    %edx
80105f79:	59                   	pop    %ecx
80105f7a:	53                   	push   %ebx
80105f7b:	50                   	push   %eax
80105f7c:	e8 ff e7 ff ff       	call   80104780 <getwmapinfo_helper>
80105f81:	83 c4 10             	add    $0x10,%esp
80105f84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105f87:	c9                   	leave  
80105f88:	c3                   	ret    
80105f89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    return FAILED;
80105f90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105f95:	eb ed                	jmp    80105f84 <sys_getwmapinfo+0x44>

80105f97 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80105f97:	1e                   	push   %ds
  pushl %es
80105f98:	06                   	push   %es
  pushl %fs
80105f99:	0f a0                	push   %fs
  pushl %gs
80105f9b:	0f a8                	push   %gs
  pushal
80105f9d:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80105f9e:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80105fa2:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80105fa4:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80105fa6:	54                   	push   %esp
  call trap
80105fa7:	e8 c4 00 00 00       	call   80106070 <trap>
  addl $4, %esp
80105fac:	83 c4 04             	add    $0x4,%esp

80105faf <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80105faf:	61                   	popa   
  popl %gs
80105fb0:	0f a9                	pop    %gs
  popl %fs
80105fb2:	0f a1                	pop    %fs
  popl %es
80105fb4:	07                   	pop    %es
  popl %ds
80105fb5:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80105fb6:	83 c4 08             	add    $0x8,%esp
  iret
80105fb9:	cf                   	iret   
80105fba:	66 90                	xchg   %ax,%ax
80105fbc:	66 90                	xchg   %ax,%ax
80105fbe:	66 90                	xchg   %ax,%ax

80105fc0 <tvinit>:
// in vm.c
extern int mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm);

void
tvinit(void)
{
80105fc0:	55                   	push   %ebp
  int i;

  for(i = 0; i < 256; i++)
80105fc1:	31 c0                	xor    %eax,%eax
{
80105fc3:	89 e5                	mov    %esp,%ebp
80105fc5:	83 ec 08             	sub    $0x8,%esp
80105fc8:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80105fcf:	90                   	nop
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80105fd0:	8b 14 85 08 b0 10 80 	mov    -0x7fef4ff8(,%eax,4),%edx
80105fd7:	c7 04 c5 c2 9d 11 80 	movl   $0x8e000008,-0x7fee623e(,%eax,8)
80105fde:	08 00 00 8e 
80105fe2:	66 89 14 c5 c0 9d 11 	mov    %dx,-0x7fee6240(,%eax,8)
80105fe9:	80 
80105fea:	c1 ea 10             	shr    $0x10,%edx
80105fed:	66 89 14 c5 c6 9d 11 	mov    %dx,-0x7fee623a(,%eax,8)
80105ff4:	80 
  for(i = 0; i < 256; i++)
80105ff5:	83 c0 01             	add    $0x1,%eax
80105ff8:	3d 00 01 00 00       	cmp    $0x100,%eax
80105ffd:	75 d1                	jne    80105fd0 <tvinit+0x10>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);

  initlock(&tickslock, "time");
80105fff:	83 ec 08             	sub    $0x8,%esp
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106002:	a1 08 b1 10 80       	mov    0x8010b108,%eax
80106007:	c7 05 c2 9f 11 80 08 	movl   $0xef000008,0x80119fc2
8010600e:	00 00 ef 
  initlock(&tickslock, "time");
80106011:	68 29 83 10 80       	push   $0x80108329
80106016:	68 80 9d 11 80       	push   $0x80119d80
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010601b:	66 a3 c0 9f 11 80    	mov    %ax,0x80119fc0
80106021:	c1 e8 10             	shr    $0x10,%eax
80106024:	66 a3 c6 9f 11 80    	mov    %ax,0x80119fc6
  initlock(&tickslock, "time");
8010602a:	e8 71 e9 ff ff       	call   801049a0 <initlock>
}
8010602f:	83 c4 10             	add    $0x10,%esp
80106032:	c9                   	leave  
80106033:	c3                   	ret    
80106034:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010603b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010603f:	90                   	nop

80106040 <idtinit>:

void
idtinit(void)
{
80106040:	55                   	push   %ebp
  pd[0] = size-1;
80106041:	b8 ff 07 00 00       	mov    $0x7ff,%eax
80106046:	89 e5                	mov    %esp,%ebp
80106048:	83 ec 10             	sub    $0x10,%esp
8010604b:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
8010604f:	b8 c0 9d 11 80       	mov    $0x80119dc0,%eax
80106054:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80106058:	c1 e8 10             	shr    $0x10,%eax
8010605b:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
8010605f:	8d 45 fa             	lea    -0x6(%ebp),%eax
80106062:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80106065:	c9                   	leave  
80106066:	c3                   	ret    
80106067:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010606e:	66 90                	xchg   %ax,%ax

80106070 <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106070:	55                   	push   %ebp
80106071:	89 e5                	mov    %esp,%ebp
80106073:	57                   	push   %edi
80106074:	56                   	push   %esi
80106075:	53                   	push   %ebx
80106076:	83 ec 2c             	sub    $0x2c,%esp
80106079:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010607c:	8b 43 30             	mov    0x30(%ebx),%eax
8010607f:	83 f8 40             	cmp    $0x40,%eax
80106082:	0f 84 38 01 00 00    	je     801061c0 <trap+0x150>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80106088:	83 e8 0e             	sub    $0xe,%eax
8010608b:	83 f8 31             	cmp    $0x31,%eax
8010608e:	0f 87 8c 00 00 00    	ja     80106120 <trap+0xb0>
80106094:	ff 24 85 e4 83 10 80 	jmp    *-0x7fef7c1c(,%eax,4)
8010609b:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
8010609f:	90                   	nop
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
801060a0:	e8 eb d8 ff ff       	call   80103990 <cpuid>
801060a5:	85 c0                	test   %eax,%eax
801060a7:	0f 84 fb 02 00 00    	je     801063a8 <trap+0x338>
    }
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE:
    ideintr();
    lapiceoi();
801060ad:	e8 6e c8 ff ff       	call   80102920 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801060b2:	e8 f9 d8 ff ff       	call   801039b0 <myproc>
801060b7:	85 c0                	test   %eax,%eax
801060b9:	74 1d                	je     801060d8 <trap+0x68>
801060bb:	e8 f0 d8 ff ff       	call   801039b0 <myproc>
801060c0:	8b 50 24             	mov    0x24(%eax),%edx
801060c3:	85 d2                	test   %edx,%edx
801060c5:	74 11                	je     801060d8 <trap+0x68>
801060c7:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801060cb:	83 e0 03             	and    $0x3,%eax
801060ce:	66 83 f8 03          	cmp    $0x3,%ax
801060d2:	0f 84 88 02 00 00    	je     80106360 <trap+0x2f0>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
801060d8:	e8 d3 d8 ff ff       	call   801039b0 <myproc>
801060dd:	85 c0                	test   %eax,%eax
801060df:	74 0f                	je     801060f0 <trap+0x80>
801060e1:	e8 ca d8 ff ff       	call   801039b0 <myproc>
801060e6:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801060ea:	0f 84 b8 00 00 00    	je     801061a8 <trap+0x138>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801060f0:	e8 bb d8 ff ff       	call   801039b0 <myproc>
801060f5:	85 c0                	test   %eax,%eax
801060f7:	74 1d                	je     80106116 <trap+0xa6>
801060f9:	e8 b2 d8 ff ff       	call   801039b0 <myproc>
801060fe:	8b 40 24             	mov    0x24(%eax),%eax
80106101:	85 c0                	test   %eax,%eax
80106103:	74 11                	je     80106116 <trap+0xa6>
80106105:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80106109:	83 e0 03             	and    $0x3,%eax
8010610c:	66 83 f8 03          	cmp    $0x3,%ax
80106110:	0f 84 d7 00 00 00    	je     801061ed <trap+0x17d>
    exit();
}
80106116:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106119:	5b                   	pop    %ebx
8010611a:	5e                   	pop    %esi
8010611b:	5f                   	pop    %edi
8010611c:	5d                   	pop    %ebp
8010611d:	c3                   	ret    
8010611e:	66 90                	xchg   %ax,%ax
    if(myproc() == 0 || (tf->cs&3) == 0){
80106120:	e8 8b d8 ff ff       	call   801039b0 <myproc>
80106125:	85 c0                	test   %eax,%eax
80106127:	0f 84 c2 03 00 00    	je     801064ef <trap+0x47f>
8010612d:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80106131:	0f 84 b8 03 00 00    	je     801064ef <trap+0x47f>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106137:	0f 20 d1             	mov    %cr2,%ecx
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010613a:	8b 53 38             	mov    0x38(%ebx),%edx
8010613d:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80106140:	89 55 dc             	mov    %edx,-0x24(%ebp)
80106143:	e8 48 d8 ff ff       	call   80103990 <cpuid>
80106148:	8b 73 30             	mov    0x30(%ebx),%esi
8010614b:	89 c7                	mov    %eax,%edi
8010614d:	8b 43 34             	mov    0x34(%ebx),%eax
80106150:	89 45 e4             	mov    %eax,-0x1c(%ebp)
            myproc()->pid, myproc()->name, tf->trapno,
80106153:	e8 58 d8 ff ff       	call   801039b0 <myproc>
80106158:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010615b:	e8 50 d8 ff ff       	call   801039b0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106160:	8b 4d d8             	mov    -0x28(%ebp),%ecx
80106163:	8b 55 dc             	mov    -0x24(%ebp),%edx
80106166:	51                   	push   %ecx
80106167:	52                   	push   %edx
80106168:	57                   	push   %edi
80106169:	ff 75 e4             	push   -0x1c(%ebp)
8010616c:	56                   	push   %esi
            myproc()->pid, myproc()->name, tf->trapno,
8010616d:	8b 75 e0             	mov    -0x20(%ebp),%esi
80106170:	83 c6 6c             	add    $0x6c,%esi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106173:	56                   	push   %esi
80106174:	ff 70 10             	push   0x10(%eax)
80106177:	68 a0 83 10 80       	push   $0x801083a0
8010617c:	e8 1f a5 ff ff       	call   801006a0 <cprintf>
    myproc()->killed = 1;
80106181:	83 c4 20             	add    $0x20,%esp
80106184:	e8 27 d8 ff ff       	call   801039b0 <myproc>
80106189:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106190:	e8 1b d8 ff ff       	call   801039b0 <myproc>
80106195:	85 c0                	test   %eax,%eax
80106197:	0f 85 1e ff ff ff    	jne    801060bb <trap+0x4b>
8010619d:	e9 36 ff ff ff       	jmp    801060d8 <trap+0x68>
801061a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  if(myproc() && myproc()->state == RUNNING &&
801061a8:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801061ac:	0f 85 3e ff ff ff    	jne    801060f0 <trap+0x80>
    yield();
801061b2:	e8 b9 de ff ff       	call   80104070 <yield>
801061b7:	e9 34 ff ff ff       	jmp    801060f0 <trap+0x80>
801061bc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    if(myproc()->killed)
801061c0:	e8 eb d7 ff ff       	call   801039b0 <myproc>
801061c5:	8b 70 24             	mov    0x24(%eax),%esi
801061c8:	85 f6                	test   %esi,%esi
801061ca:	0f 85 c8 01 00 00    	jne    80106398 <trap+0x328>
    myproc()->tf = tf;
801061d0:	e8 db d7 ff ff       	call   801039b0 <myproc>
801061d5:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
801061d8:	e8 53 ee ff ff       	call   80105030 <syscall>
    if(myproc()->killed)
801061dd:	e8 ce d7 ff ff       	call   801039b0 <myproc>
801061e2:	8b 48 24             	mov    0x24(%eax),%ecx
801061e5:	85 c9                	test   %ecx,%ecx
801061e7:	0f 84 29 ff ff ff    	je     80106116 <trap+0xa6>
}
801061ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061f0:	5b                   	pop    %ebx
801061f1:	5e                   	pop    %esi
801061f2:	5f                   	pop    %edi
801061f3:	5d                   	pop    %ebp
      exit();
801061f4:	e9 17 dc ff ff       	jmp    80103e10 <exit>
801061f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106200:	8b 7b 38             	mov    0x38(%ebx),%edi
80106203:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
80106207:	e8 84 d7 ff ff       	call   80103990 <cpuid>
8010620c:	57                   	push   %edi
8010620d:	56                   	push   %esi
8010620e:	50                   	push   %eax
8010620f:	68 48 83 10 80       	push   $0x80108348
80106214:	e8 87 a4 ff ff       	call   801006a0 <cprintf>
    lapiceoi();
80106219:	e8 02 c7 ff ff       	call   80102920 <lapiceoi>
    break;
8010621e:	83 c4 10             	add    $0x10,%esp
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106221:	e8 8a d7 ff ff       	call   801039b0 <myproc>
80106226:	85 c0                	test   %eax,%eax
80106228:	0f 85 8d fe ff ff    	jne    801060bb <trap+0x4b>
8010622e:	e9 a5 fe ff ff       	jmp    801060d8 <trap+0x68>
80106233:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80106237:	90                   	nop
    kbdintr();
80106238:	e8 a3 c5 ff ff       	call   801027e0 <kbdintr>
    lapiceoi();
8010623d:	e8 de c6 ff ff       	call   80102920 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106242:	e8 69 d7 ff ff       	call   801039b0 <myproc>
80106247:	85 c0                	test   %eax,%eax
80106249:	0f 85 6c fe ff ff    	jne    801060bb <trap+0x4b>
8010624f:	e9 84 fe ff ff       	jmp    801060d8 <trap+0x68>
80106254:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    uartintr();
80106258:	e8 33 04 00 00       	call   80106690 <uartintr>
    lapiceoi();
8010625d:	e8 be c6 ff ff       	call   80102920 <lapiceoi>
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80106262:	e8 49 d7 ff ff       	call   801039b0 <myproc>
80106267:	85 c0                	test   %eax,%eax
80106269:	0f 85 4c fe ff ff    	jne    801060bb <trap+0x4b>
8010626f:	e9 64 fe ff ff       	jmp    801060d8 <trap+0x68>
80106274:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    ideintr();
80106278:	e8 d3 bf ff ff       	call   80102250 <ideintr>
8010627d:	e9 2b fe ff ff       	jmp    801060ad <trap+0x3d>
80106282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
80106288:	0f 20 d7             	mov    %cr2,%edi
    struct proc *p = myproc();
8010628b:	e8 20 d7 ff ff       	call   801039b0 <myproc>
80106290:	89 c6                	mov    %eax,%esi
    if (p == 0) {
80106292:	85 c0                	test   %eax,%eax
80106294:	0f 84 18 fe ff ff    	je     801060b2 <trap+0x42>
    uint found_index = valid_memory_mapping_index(p, faulting_addr);
8010629a:	83 ec 08             	sub    $0x8,%esp
8010629d:	57                   	push   %edi
8010629e:	50                   	push   %eax
8010629f:	e8 dc e1 ff ff       	call   80104480 <valid_memory_mapping_index>
    if (found_index >= 0 && found_index < MAX_NUM_WMAPS) { // lazy allocation
801062a4:	83 c4 10             	add    $0x10,%esp
    uint found_index = valid_memory_mapping_index(p, faulting_addr);
801062a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if (found_index >= 0 && found_index < MAX_NUM_WMAPS) { // lazy allocation
801062aa:	83 f8 0f             	cmp    $0xf,%eax
801062ad:	0f 87 bd 00 00 00    	ja     80106370 <trap+0x300>
      pte_t *pte = pte = walkpgdir(p->pgdir, (void*)faulting_addr, 0);
801062b3:	83 ec 04             	sub    $0x4,%esp
801062b6:	6a 00                	push   $0x0
801062b8:	57                   	push   %edi
801062b9:	ff 76 04             	push   0x4(%esi)
801062bc:	e8 9f 0f 00 00       	call   80107260 <walkpgdir>
      if((*pte & PTE_P) && (*pte & PTE_COW)) {
801062c1:	83 c4 10             	add    $0x10,%esp
801062c4:	8b 10                	mov    (%eax),%edx
      pte_t *pte = pte = walkpgdir(p->pgdir, (void*)faulting_addr, 0);
801062c6:	89 c1                	mov    %eax,%ecx
      if((*pte & PTE_P) && (*pte & PTE_COW)) {
801062c8:	89 d0                	mov    %edx,%eax
801062ca:	25 01 02 00 00       	and    $0x201,%eax
801062cf:	3d 01 02 00 00       	cmp    $0x201,%eax
801062d4:	0f 84 16 01 00 00    	je     801063f0 <trap+0x380>
        char *new_page = kalloc();  // allocate physical page
801062da:	e8 b1 c3 ff ff       	call   80102690 <kalloc>
801062df:	89 c1                	mov    %eax,%ecx
        if (!new_page) {  // allocation failed
801062e1:	85 c0                	test   %eax,%eax
801062e3:	0f 84 f7 00 00 00    	je     801063e0 <trap+0x370>
        if (region->flags & MAP_ANONYMOUS) { 
801062e9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801062ec:	8d 04 80             	lea    (%eax,%eax,4),%eax
801062ef:	8d 04 86             	lea    (%esi,%eax,4),%eax
801062f2:	f6 80 84 00 00 00 04 	testb  $0x4,0x84(%eax)
801062f9:	0f 84 79 01 00 00    	je     80106478 <trap+0x408>
          memset(new_page, 0, PAGE_SIZE);
801062ff:	83 ec 04             	sub    $0x4,%esp
80106302:	89 4d e0             	mov    %ecx,-0x20(%ebp)
80106305:	68 00 10 00 00       	push   $0x1000
8010630a:	6a 00                	push   $0x0
8010630c:	51                   	push   %ecx
8010630d:	e8 1e e9 ff ff       	call   80104c30 <memset>
80106312:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80106315:	83 c4 10             	add    $0x10,%esp
        if (mappages(p->pgdir, (void*)page_addr, PAGE_SIZE, V2P(new_page), PTE_W | PTE_U) < 0) {
80106318:	83 ec 0c             	sub    $0xc,%esp
8010631b:	8d 81 00 00 00 80    	lea    -0x80000000(%ecx),%eax
      uint page_addr = PGROUNDDOWN(faulting_addr); // page-aligned VA
80106321:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
        if (mappages(p->pgdir, (void*)page_addr, PAGE_SIZE, V2P(new_page), PTE_W | PTE_U) < 0) {
80106327:	89 4d e0             	mov    %ecx,-0x20(%ebp)
8010632a:	6a 06                	push   $0x6
8010632c:	50                   	push   %eax
8010632d:	68 00 10 00 00       	push   $0x1000
80106332:	57                   	push   %edi
80106333:	ff 76 04             	push   0x4(%esi)
80106336:	e8 b5 0f 00 00       	call   801072f0 <mappages>
8010633b:	83 c4 20             	add    $0x20,%esp
8010633e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80106341:	85 c0                	test   %eax,%eax
80106343:	0f 88 5b 01 00 00    	js     801064a4 <trap+0x434>
        region->n_loaded_pages++; // increment num pages
80106349:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010634c:	8d 04 80             	lea    (%eax,%eax,4),%eax
8010634f:	83 84 86 8c 00 00 00 	addl   $0x1,0x8c(%esi,%eax,4)
80106356:	01 
80106357:	e9 56 fd ff ff       	jmp    801060b2 <trap+0x42>
8010635c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    exit();
80106360:	e8 ab da ff ff       	call   80103e10 <exit>
80106365:	e9 6e fd ff ff       	jmp    801060d8 <trap+0x68>
8010636a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
        cprintf("Segmentation Fault\n");
80106370:	83 ec 0c             	sub    $0xc,%esp
80106373:	68 2e 83 10 80       	push   $0x8010832e
80106378:	e8 23 a3 ff ff       	call   801006a0 <cprintf>
        myproc()->killed = 1;
8010637d:	e8 2e d6 ff ff       	call   801039b0 <myproc>
80106382:	83 c4 10             	add    $0x10,%esp
80106385:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010638c:	e9 21 fd ff ff       	jmp    801060b2 <trap+0x42>
80106391:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
      exit();
80106398:	e8 73 da ff ff       	call   80103e10 <exit>
8010639d:	e9 2e fe ff ff       	jmp    801061d0 <trap+0x160>
801063a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
      acquire(&tickslock);
801063a8:	83 ec 0c             	sub    $0xc,%esp
801063ab:	68 80 9d 11 80       	push   $0x80119d80
801063b0:	e8 bb e7 ff ff       	call   80104b70 <acquire>
      wakeup(&ticks);
801063b5:	c7 04 24 60 9d 11 80 	movl   $0x80119d60,(%esp)
      ticks++;
801063bc:	83 05 60 9d 11 80 01 	addl   $0x1,0x80119d60
      wakeup(&ticks);
801063c3:	e8 b8 dd ff ff       	call   80104180 <wakeup>
      release(&tickslock);
801063c8:	c7 04 24 80 9d 11 80 	movl   $0x80119d80,(%esp)
801063cf:	e8 3c e7 ff ff       	call   80104b10 <release>
801063d4:	83 c4 10             	add    $0x10,%esp
    lapiceoi();
801063d7:	e9 d1 fc ff ff       	jmp    801060ad <trap+0x3d>
801063dc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
          p->killed = 1;
801063e0:	c7 46 24 01 00 00 00 	movl   $0x1,0x24(%esi)
          break;
801063e7:	e9 c6 fc ff ff       	jmp    801060b2 <trap+0x42>
801063ec:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801063f0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
801063f3:	89 55 e0             	mov    %edx,-0x20(%ebp)
        char *new_page = kalloc();
801063f6:	e8 95 c2 ff ff       	call   80102690 <kalloc>
        if (!new_page) {  // allocation failed
801063fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
801063fe:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80106401:	85 c0                	test   %eax,%eax
        char *new_page = kalloc();
80106403:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if (!new_page) {  // allocation failed
80106406:	74 d8                	je     801063e0 <trap+0x370>
        uint pa = PTE_ADDR(*pte);
80106408:	89 d0                	mov    %edx,%eax
        memmove(new_page, (char*)P2V(pa), PGSIZE);
8010640a:	83 ec 04             	sub    $0x4,%esp
8010640d:	89 4d dc             	mov    %ecx,-0x24(%ebp)
        uint pa = PTE_ADDR(*pte);
80106410:	25 00 f0 ff ff       	and    $0xfffff000,%eax
        memmove(new_page, (char*)P2V(pa), PGSIZE);
80106415:	68 00 10 00 00       	push   $0x1000
8010641a:	05 00 00 00 80       	add    $0x80000000,%eax
        uint pa = PTE_ADDR(*pte);
8010641f:	89 55 e0             	mov    %edx,-0x20(%ebp)
        memmove(new_page, (char*)P2V(pa), PGSIZE);
80106422:	50                   	push   %eax
80106423:	ff 75 e4             	push   -0x1c(%ebp)
80106426:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80106429:	e8 a2 e8 ff ff       	call   80104cd0 <memmove>
        if(mappages(p->pgdir, (void*)faulting_addr, PGSIZE, V2P(new_page), PTE_W | PTE_U) < 0){
8010642e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106431:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80106438:	05 00 00 00 80       	add    $0x80000000,%eax
8010643d:	50                   	push   %eax
8010643e:	68 00 10 00 00       	push   $0x1000
80106443:	57                   	push   %edi
80106444:	ff 76 04             	push   0x4(%esi)
80106447:	89 45 d8             	mov    %eax,-0x28(%ebp)
8010644a:	e8 a1 0e 00 00       	call   801072f0 <mappages>
8010644f:	83 c4 20             	add    $0x20,%esp
80106452:	8b 55 e0             	mov    -0x20(%ebp),%edx
80106455:	8b 4d dc             	mov    -0x24(%ebp),%ecx
80106458:	85 c0                	test   %eax,%eax
8010645a:	78 60                	js     801064bc <trap+0x44c>
        ref_counts[pa / PGSIZE]--;
8010645c:	89 d0                	mov    %edx,%eax
8010645e:	c1 e8 0c             	shr    $0xc,%eax
80106461:	83 2c 85 e0 a5 11 80 	subl   $0x1,-0x7fee5a20(,%eax,4)
80106468:	01 
        if(ref_counts[pa / PGSIZE] == 0) {
80106469:	74 6b                	je     801064d6 <trap+0x466>
        *pte = V2P(new_page) | PTE_U | PTE_W | PTE_P;  // Mark as writable
8010646b:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010646e:	83 c8 07             	or     $0x7,%eax
80106471:	89 01                	mov    %eax,(%ecx)
80106473:	e9 3a fc ff ff       	jmp    801060b2 <trap+0x42>
          if (fileread(p->ofile[region->fd], new_page, PAGE_SIZE) != PAGE_SIZE) {
80106478:	83 ec 04             	sub    $0x4,%esp
8010647b:	89 4d e0             	mov    %ecx,-0x20(%ebp)
8010647e:	68 00 10 00 00       	push   $0x1000
80106483:	51                   	push   %ecx
80106484:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
8010648a:	ff 74 86 28          	push   0x28(%esi,%eax,4)
8010648e:	e8 9d ab ff ff       	call   80101030 <fileread>
80106493:	83 c4 10             	add    $0x10,%esp
80106496:	8b 4d e0             	mov    -0x20(%ebp),%ecx
80106499:	3d 00 10 00 00       	cmp    $0x1000,%eax
8010649e:	0f 84 74 fe ff ff    	je     80106318 <trap+0x2a8>
          kfree(new_page);
801064a4:	83 ec 0c             	sub    $0xc,%esp
801064a7:	51                   	push   %ecx
801064a8:	e8 23 c0 ff ff       	call   801024d0 <kfree>
          p->killed = 1;
801064ad:	c7 46 24 01 00 00 00 	movl   $0x1,0x24(%esi)
          break;
801064b4:	83 c4 10             	add    $0x10,%esp
801064b7:	e9 f6 fb ff ff       	jmp    801060b2 <trap+0x42>
          kfree(new_page);
801064bc:	83 ec 0c             	sub    $0xc,%esp
801064bf:	ff 75 e4             	push   -0x1c(%ebp)
801064c2:	e8 09 c0 ff ff       	call   801024d0 <kfree>
          p->killed = 1;
801064c7:	c7 46 24 01 00 00 00 	movl   $0x1,0x24(%esi)
          break;
801064ce:	83 c4 10             	add    $0x10,%esp
801064d1:	e9 dc fb ff ff       	jmp    801060b2 <trap+0x42>
          kfree((char*)P2V(pa));
801064d6:	83 ec 0c             	sub    $0xc,%esp
801064d9:	ff 75 d4             	push   -0x2c(%ebp)
801064dc:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
801064df:	e8 ec bf ff ff       	call   801024d0 <kfree>
801064e4:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801064e7:	83 c4 10             	add    $0x10,%esp
801064ea:	e9 7c ff ff ff       	jmp    8010646b <trap+0x3fb>
801064ef:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801064f2:	8b 73 38             	mov    0x38(%ebx),%esi
801064f5:	e8 96 d4 ff ff       	call   80103990 <cpuid>
801064fa:	83 ec 0c             	sub    $0xc,%esp
801064fd:	57                   	push   %edi
801064fe:	56                   	push   %esi
801064ff:	50                   	push   %eax
80106500:	ff 73 30             	push   0x30(%ebx)
80106503:	68 6c 83 10 80       	push   $0x8010836c
80106508:	e8 93 a1 ff ff       	call   801006a0 <cprintf>
      panic("trap");
8010650d:	83 c4 14             	add    $0x14,%esp
80106510:	68 42 83 10 80       	push   $0x80108342
80106515:	e8 66 9e ff ff       	call   80100380 <panic>
8010651a:	66 90                	xchg   %ax,%ax
8010651c:	66 90                	xchg   %ax,%ax
8010651e:	66 90                	xchg   %ax,%ax

80106520 <uartgetc>:
}

static int
uartgetc(void)
{
  if(!uart)
80106520:	a1 c0 a5 11 80       	mov    0x8011a5c0,%eax
80106525:	85 c0                	test   %eax,%eax
80106527:	74 17                	je     80106540 <uartgetc+0x20>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106529:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010652e:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
8010652f:	a8 01                	test   $0x1,%al
80106531:	74 0d                	je     80106540 <uartgetc+0x20>
80106533:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106538:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80106539:	0f b6 c0             	movzbl %al,%eax
8010653c:	c3                   	ret    
8010653d:	8d 76 00             	lea    0x0(%esi),%esi
    return -1;
80106540:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80106545:	c3                   	ret    
80106546:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010654d:	8d 76 00             	lea    0x0(%esi),%esi

80106550 <uartinit>:
{
80106550:	55                   	push   %ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106551:	31 c9                	xor    %ecx,%ecx
80106553:	89 c8                	mov    %ecx,%eax
80106555:	89 e5                	mov    %esp,%ebp
80106557:	57                   	push   %edi
80106558:	bf fa 03 00 00       	mov    $0x3fa,%edi
8010655d:	56                   	push   %esi
8010655e:	89 fa                	mov    %edi,%edx
80106560:	53                   	push   %ebx
80106561:	83 ec 1c             	sub    $0x1c,%esp
80106564:	ee                   	out    %al,(%dx)
80106565:	be fb 03 00 00       	mov    $0x3fb,%esi
8010656a:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010656f:	89 f2                	mov    %esi,%edx
80106571:	ee                   	out    %al,(%dx)
80106572:	b8 0c 00 00 00       	mov    $0xc,%eax
80106577:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010657c:	ee                   	out    %al,(%dx)
8010657d:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80106582:	89 c8                	mov    %ecx,%eax
80106584:	89 da                	mov    %ebx,%edx
80106586:	ee                   	out    %al,(%dx)
80106587:	b8 03 00 00 00       	mov    $0x3,%eax
8010658c:	89 f2                	mov    %esi,%edx
8010658e:	ee                   	out    %al,(%dx)
8010658f:	ba fc 03 00 00       	mov    $0x3fc,%edx
80106594:	89 c8                	mov    %ecx,%eax
80106596:	ee                   	out    %al,(%dx)
80106597:	b8 01 00 00 00       	mov    $0x1,%eax
8010659c:	89 da                	mov    %ebx,%edx
8010659e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010659f:	ba fd 03 00 00       	mov    $0x3fd,%edx
801065a4:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801065a5:	3c ff                	cmp    $0xff,%al
801065a7:	74 78                	je     80106621 <uartinit+0xd1>
  uart = 1;
801065a9:	c7 05 c0 a5 11 80 01 	movl   $0x1,0x8011a5c0
801065b0:	00 00 00 
801065b3:	89 fa                	mov    %edi,%edx
801065b5:	ec                   	in     (%dx),%al
801065b6:	ba f8 03 00 00       	mov    $0x3f8,%edx
801065bb:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801065bc:	83 ec 08             	sub    $0x8,%esp
  for(p="xv6...\n"; *p; p++)
801065bf:	bf ac 84 10 80       	mov    $0x801084ac,%edi
801065c4:	be fd 03 00 00       	mov    $0x3fd,%esi
  ioapicenable(IRQ_COM1, 0);
801065c9:	6a 00                	push   $0x0
801065cb:	6a 04                	push   $0x4
801065cd:	e8 be be ff ff       	call   80102490 <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801065d2:	c6 45 e7 78          	movb   $0x78,-0x19(%ebp)
  ioapicenable(IRQ_COM1, 0);
801065d6:	83 c4 10             	add    $0x10,%esp
801065d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  if(!uart)
801065e0:	a1 c0 a5 11 80       	mov    0x8011a5c0,%eax
801065e5:	bb 80 00 00 00       	mov    $0x80,%ebx
801065ea:	85 c0                	test   %eax,%eax
801065ec:	75 14                	jne    80106602 <uartinit+0xb2>
801065ee:	eb 23                	jmp    80106613 <uartinit+0xc3>
    microdelay(10);
801065f0:	83 ec 0c             	sub    $0xc,%esp
801065f3:	6a 0a                	push   $0xa
801065f5:	e8 46 c3 ff ff       	call   80102940 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801065fa:	83 c4 10             	add    $0x10,%esp
801065fd:	83 eb 01             	sub    $0x1,%ebx
80106600:	74 07                	je     80106609 <uartinit+0xb9>
80106602:	89 f2                	mov    %esi,%edx
80106604:	ec                   	in     (%dx),%al
80106605:	a8 20                	test   $0x20,%al
80106607:	74 e7                	je     801065f0 <uartinit+0xa0>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106609:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
8010660d:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106612:	ee                   	out    %al,(%dx)
  for(p="xv6...\n"; *p; p++)
80106613:	0f b6 47 01          	movzbl 0x1(%edi),%eax
80106617:	83 c7 01             	add    $0x1,%edi
8010661a:	88 45 e7             	mov    %al,-0x19(%ebp)
8010661d:	84 c0                	test   %al,%al
8010661f:	75 bf                	jne    801065e0 <uartinit+0x90>
}
80106621:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106624:	5b                   	pop    %ebx
80106625:	5e                   	pop    %esi
80106626:	5f                   	pop    %edi
80106627:	5d                   	pop    %ebp
80106628:	c3                   	ret    
80106629:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80106630 <uartputc>:
  if(!uart)
80106630:	a1 c0 a5 11 80       	mov    0x8011a5c0,%eax
80106635:	85 c0                	test   %eax,%eax
80106637:	74 47                	je     80106680 <uartputc+0x50>
{
80106639:	55                   	push   %ebp
8010663a:	89 e5                	mov    %esp,%ebp
8010663c:	56                   	push   %esi
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010663d:	be fd 03 00 00       	mov    $0x3fd,%esi
80106642:	53                   	push   %ebx
80106643:	bb 80 00 00 00       	mov    $0x80,%ebx
80106648:	eb 18                	jmp    80106662 <uartputc+0x32>
8010664a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
    microdelay(10);
80106650:	83 ec 0c             	sub    $0xc,%esp
80106653:	6a 0a                	push   $0xa
80106655:	e8 e6 c2 ff ff       	call   80102940 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010665a:	83 c4 10             	add    $0x10,%esp
8010665d:	83 eb 01             	sub    $0x1,%ebx
80106660:	74 07                	je     80106669 <uartputc+0x39>
80106662:	89 f2                	mov    %esi,%edx
80106664:	ec                   	in     (%dx),%al
80106665:	a8 20                	test   $0x20,%al
80106667:	74 e7                	je     80106650 <uartputc+0x20>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106669:	8b 45 08             	mov    0x8(%ebp),%eax
8010666c:	ba f8 03 00 00       	mov    $0x3f8,%edx
80106671:	ee                   	out    %al,(%dx)
}
80106672:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106675:	5b                   	pop    %ebx
80106676:	5e                   	pop    %esi
80106677:	5d                   	pop    %ebp
80106678:	c3                   	ret    
80106679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106680:	c3                   	ret    
80106681:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80106688:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010668f:	90                   	nop

80106690 <uartintr>:

void
uartintr(void)
{
80106690:	55                   	push   %ebp
80106691:	89 e5                	mov    %esp,%ebp
80106693:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80106696:	68 20 65 10 80       	push   $0x80106520
8010669b:	e8 e0 a1 ff ff       	call   80100880 <consoleintr>
}
801066a0:	83 c4 10             	add    $0x10,%esp
801066a3:	c9                   	leave  
801066a4:	c3                   	ret    

801066a5 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801066a5:	6a 00                	push   $0x0
  pushl $0
801066a7:	6a 00                	push   $0x0
  jmp alltraps
801066a9:	e9 e9 f8 ff ff       	jmp    80105f97 <alltraps>

801066ae <vector1>:
.globl vector1
vector1:
  pushl $0
801066ae:	6a 00                	push   $0x0
  pushl $1
801066b0:	6a 01                	push   $0x1
  jmp alltraps
801066b2:	e9 e0 f8 ff ff       	jmp    80105f97 <alltraps>

801066b7 <vector2>:
.globl vector2
vector2:
  pushl $0
801066b7:	6a 00                	push   $0x0
  pushl $2
801066b9:	6a 02                	push   $0x2
  jmp alltraps
801066bb:	e9 d7 f8 ff ff       	jmp    80105f97 <alltraps>

801066c0 <vector3>:
.globl vector3
vector3:
  pushl $0
801066c0:	6a 00                	push   $0x0
  pushl $3
801066c2:	6a 03                	push   $0x3
  jmp alltraps
801066c4:	e9 ce f8 ff ff       	jmp    80105f97 <alltraps>

801066c9 <vector4>:
.globl vector4
vector4:
  pushl $0
801066c9:	6a 00                	push   $0x0
  pushl $4
801066cb:	6a 04                	push   $0x4
  jmp alltraps
801066cd:	e9 c5 f8 ff ff       	jmp    80105f97 <alltraps>

801066d2 <vector5>:
.globl vector5
vector5:
  pushl $0
801066d2:	6a 00                	push   $0x0
  pushl $5
801066d4:	6a 05                	push   $0x5
  jmp alltraps
801066d6:	e9 bc f8 ff ff       	jmp    80105f97 <alltraps>

801066db <vector6>:
.globl vector6
vector6:
  pushl $0
801066db:	6a 00                	push   $0x0
  pushl $6
801066dd:	6a 06                	push   $0x6
  jmp alltraps
801066df:	e9 b3 f8 ff ff       	jmp    80105f97 <alltraps>

801066e4 <vector7>:
.globl vector7
vector7:
  pushl $0
801066e4:	6a 00                	push   $0x0
  pushl $7
801066e6:	6a 07                	push   $0x7
  jmp alltraps
801066e8:	e9 aa f8 ff ff       	jmp    80105f97 <alltraps>

801066ed <vector8>:
.globl vector8
vector8:
  pushl $8
801066ed:	6a 08                	push   $0x8
  jmp alltraps
801066ef:	e9 a3 f8 ff ff       	jmp    80105f97 <alltraps>

801066f4 <vector9>:
.globl vector9
vector9:
  pushl $0
801066f4:	6a 00                	push   $0x0
  pushl $9
801066f6:	6a 09                	push   $0x9
  jmp alltraps
801066f8:	e9 9a f8 ff ff       	jmp    80105f97 <alltraps>

801066fd <vector10>:
.globl vector10
vector10:
  pushl $10
801066fd:	6a 0a                	push   $0xa
  jmp alltraps
801066ff:	e9 93 f8 ff ff       	jmp    80105f97 <alltraps>

80106704 <vector11>:
.globl vector11
vector11:
  pushl $11
80106704:	6a 0b                	push   $0xb
  jmp alltraps
80106706:	e9 8c f8 ff ff       	jmp    80105f97 <alltraps>

8010670b <vector12>:
.globl vector12
vector12:
  pushl $12
8010670b:	6a 0c                	push   $0xc
  jmp alltraps
8010670d:	e9 85 f8 ff ff       	jmp    80105f97 <alltraps>

80106712 <vector13>:
.globl vector13
vector13:
  pushl $13
80106712:	6a 0d                	push   $0xd
  jmp alltraps
80106714:	e9 7e f8 ff ff       	jmp    80105f97 <alltraps>

80106719 <vector14>:
.globl vector14
vector14:
  pushl $14
80106719:	6a 0e                	push   $0xe
  jmp alltraps
8010671b:	e9 77 f8 ff ff       	jmp    80105f97 <alltraps>

80106720 <vector15>:
.globl vector15
vector15:
  pushl $0
80106720:	6a 00                	push   $0x0
  pushl $15
80106722:	6a 0f                	push   $0xf
  jmp alltraps
80106724:	e9 6e f8 ff ff       	jmp    80105f97 <alltraps>

80106729 <vector16>:
.globl vector16
vector16:
  pushl $0
80106729:	6a 00                	push   $0x0
  pushl $16
8010672b:	6a 10                	push   $0x10
  jmp alltraps
8010672d:	e9 65 f8 ff ff       	jmp    80105f97 <alltraps>

80106732 <vector17>:
.globl vector17
vector17:
  pushl $17
80106732:	6a 11                	push   $0x11
  jmp alltraps
80106734:	e9 5e f8 ff ff       	jmp    80105f97 <alltraps>

80106739 <vector18>:
.globl vector18
vector18:
  pushl $0
80106739:	6a 00                	push   $0x0
  pushl $18
8010673b:	6a 12                	push   $0x12
  jmp alltraps
8010673d:	e9 55 f8 ff ff       	jmp    80105f97 <alltraps>

80106742 <vector19>:
.globl vector19
vector19:
  pushl $0
80106742:	6a 00                	push   $0x0
  pushl $19
80106744:	6a 13                	push   $0x13
  jmp alltraps
80106746:	e9 4c f8 ff ff       	jmp    80105f97 <alltraps>

8010674b <vector20>:
.globl vector20
vector20:
  pushl $0
8010674b:	6a 00                	push   $0x0
  pushl $20
8010674d:	6a 14                	push   $0x14
  jmp alltraps
8010674f:	e9 43 f8 ff ff       	jmp    80105f97 <alltraps>

80106754 <vector21>:
.globl vector21
vector21:
  pushl $0
80106754:	6a 00                	push   $0x0
  pushl $21
80106756:	6a 15                	push   $0x15
  jmp alltraps
80106758:	e9 3a f8 ff ff       	jmp    80105f97 <alltraps>

8010675d <vector22>:
.globl vector22
vector22:
  pushl $0
8010675d:	6a 00                	push   $0x0
  pushl $22
8010675f:	6a 16                	push   $0x16
  jmp alltraps
80106761:	e9 31 f8 ff ff       	jmp    80105f97 <alltraps>

80106766 <vector23>:
.globl vector23
vector23:
  pushl $0
80106766:	6a 00                	push   $0x0
  pushl $23
80106768:	6a 17                	push   $0x17
  jmp alltraps
8010676a:	e9 28 f8 ff ff       	jmp    80105f97 <alltraps>

8010676f <vector24>:
.globl vector24
vector24:
  pushl $0
8010676f:	6a 00                	push   $0x0
  pushl $24
80106771:	6a 18                	push   $0x18
  jmp alltraps
80106773:	e9 1f f8 ff ff       	jmp    80105f97 <alltraps>

80106778 <vector25>:
.globl vector25
vector25:
  pushl $0
80106778:	6a 00                	push   $0x0
  pushl $25
8010677a:	6a 19                	push   $0x19
  jmp alltraps
8010677c:	e9 16 f8 ff ff       	jmp    80105f97 <alltraps>

80106781 <vector26>:
.globl vector26
vector26:
  pushl $0
80106781:	6a 00                	push   $0x0
  pushl $26
80106783:	6a 1a                	push   $0x1a
  jmp alltraps
80106785:	e9 0d f8 ff ff       	jmp    80105f97 <alltraps>

8010678a <vector27>:
.globl vector27
vector27:
  pushl $0
8010678a:	6a 00                	push   $0x0
  pushl $27
8010678c:	6a 1b                	push   $0x1b
  jmp alltraps
8010678e:	e9 04 f8 ff ff       	jmp    80105f97 <alltraps>

80106793 <vector28>:
.globl vector28
vector28:
  pushl $0
80106793:	6a 00                	push   $0x0
  pushl $28
80106795:	6a 1c                	push   $0x1c
  jmp alltraps
80106797:	e9 fb f7 ff ff       	jmp    80105f97 <alltraps>

8010679c <vector29>:
.globl vector29
vector29:
  pushl $0
8010679c:	6a 00                	push   $0x0
  pushl $29
8010679e:	6a 1d                	push   $0x1d
  jmp alltraps
801067a0:	e9 f2 f7 ff ff       	jmp    80105f97 <alltraps>

801067a5 <vector30>:
.globl vector30
vector30:
  pushl $0
801067a5:	6a 00                	push   $0x0
  pushl $30
801067a7:	6a 1e                	push   $0x1e
  jmp alltraps
801067a9:	e9 e9 f7 ff ff       	jmp    80105f97 <alltraps>

801067ae <vector31>:
.globl vector31
vector31:
  pushl $0
801067ae:	6a 00                	push   $0x0
  pushl $31
801067b0:	6a 1f                	push   $0x1f
  jmp alltraps
801067b2:	e9 e0 f7 ff ff       	jmp    80105f97 <alltraps>

801067b7 <vector32>:
.globl vector32
vector32:
  pushl $0
801067b7:	6a 00                	push   $0x0
  pushl $32
801067b9:	6a 20                	push   $0x20
  jmp alltraps
801067bb:	e9 d7 f7 ff ff       	jmp    80105f97 <alltraps>

801067c0 <vector33>:
.globl vector33
vector33:
  pushl $0
801067c0:	6a 00                	push   $0x0
  pushl $33
801067c2:	6a 21                	push   $0x21
  jmp alltraps
801067c4:	e9 ce f7 ff ff       	jmp    80105f97 <alltraps>

801067c9 <vector34>:
.globl vector34
vector34:
  pushl $0
801067c9:	6a 00                	push   $0x0
  pushl $34
801067cb:	6a 22                	push   $0x22
  jmp alltraps
801067cd:	e9 c5 f7 ff ff       	jmp    80105f97 <alltraps>

801067d2 <vector35>:
.globl vector35
vector35:
  pushl $0
801067d2:	6a 00                	push   $0x0
  pushl $35
801067d4:	6a 23                	push   $0x23
  jmp alltraps
801067d6:	e9 bc f7 ff ff       	jmp    80105f97 <alltraps>

801067db <vector36>:
.globl vector36
vector36:
  pushl $0
801067db:	6a 00                	push   $0x0
  pushl $36
801067dd:	6a 24                	push   $0x24
  jmp alltraps
801067df:	e9 b3 f7 ff ff       	jmp    80105f97 <alltraps>

801067e4 <vector37>:
.globl vector37
vector37:
  pushl $0
801067e4:	6a 00                	push   $0x0
  pushl $37
801067e6:	6a 25                	push   $0x25
  jmp alltraps
801067e8:	e9 aa f7 ff ff       	jmp    80105f97 <alltraps>

801067ed <vector38>:
.globl vector38
vector38:
  pushl $0
801067ed:	6a 00                	push   $0x0
  pushl $38
801067ef:	6a 26                	push   $0x26
  jmp alltraps
801067f1:	e9 a1 f7 ff ff       	jmp    80105f97 <alltraps>

801067f6 <vector39>:
.globl vector39
vector39:
  pushl $0
801067f6:	6a 00                	push   $0x0
  pushl $39
801067f8:	6a 27                	push   $0x27
  jmp alltraps
801067fa:	e9 98 f7 ff ff       	jmp    80105f97 <alltraps>

801067ff <vector40>:
.globl vector40
vector40:
  pushl $0
801067ff:	6a 00                	push   $0x0
  pushl $40
80106801:	6a 28                	push   $0x28
  jmp alltraps
80106803:	e9 8f f7 ff ff       	jmp    80105f97 <alltraps>

80106808 <vector41>:
.globl vector41
vector41:
  pushl $0
80106808:	6a 00                	push   $0x0
  pushl $41
8010680a:	6a 29                	push   $0x29
  jmp alltraps
8010680c:	e9 86 f7 ff ff       	jmp    80105f97 <alltraps>

80106811 <vector42>:
.globl vector42
vector42:
  pushl $0
80106811:	6a 00                	push   $0x0
  pushl $42
80106813:	6a 2a                	push   $0x2a
  jmp alltraps
80106815:	e9 7d f7 ff ff       	jmp    80105f97 <alltraps>

8010681a <vector43>:
.globl vector43
vector43:
  pushl $0
8010681a:	6a 00                	push   $0x0
  pushl $43
8010681c:	6a 2b                	push   $0x2b
  jmp alltraps
8010681e:	e9 74 f7 ff ff       	jmp    80105f97 <alltraps>

80106823 <vector44>:
.globl vector44
vector44:
  pushl $0
80106823:	6a 00                	push   $0x0
  pushl $44
80106825:	6a 2c                	push   $0x2c
  jmp alltraps
80106827:	e9 6b f7 ff ff       	jmp    80105f97 <alltraps>

8010682c <vector45>:
.globl vector45
vector45:
  pushl $0
8010682c:	6a 00                	push   $0x0
  pushl $45
8010682e:	6a 2d                	push   $0x2d
  jmp alltraps
80106830:	e9 62 f7 ff ff       	jmp    80105f97 <alltraps>

80106835 <vector46>:
.globl vector46
vector46:
  pushl $0
80106835:	6a 00                	push   $0x0
  pushl $46
80106837:	6a 2e                	push   $0x2e
  jmp alltraps
80106839:	e9 59 f7 ff ff       	jmp    80105f97 <alltraps>

8010683e <vector47>:
.globl vector47
vector47:
  pushl $0
8010683e:	6a 00                	push   $0x0
  pushl $47
80106840:	6a 2f                	push   $0x2f
  jmp alltraps
80106842:	e9 50 f7 ff ff       	jmp    80105f97 <alltraps>

80106847 <vector48>:
.globl vector48
vector48:
  pushl $0
80106847:	6a 00                	push   $0x0
  pushl $48
80106849:	6a 30                	push   $0x30
  jmp alltraps
8010684b:	e9 47 f7 ff ff       	jmp    80105f97 <alltraps>

80106850 <vector49>:
.globl vector49
vector49:
  pushl $0
80106850:	6a 00                	push   $0x0
  pushl $49
80106852:	6a 31                	push   $0x31
  jmp alltraps
80106854:	e9 3e f7 ff ff       	jmp    80105f97 <alltraps>

80106859 <vector50>:
.globl vector50
vector50:
  pushl $0
80106859:	6a 00                	push   $0x0
  pushl $50
8010685b:	6a 32                	push   $0x32
  jmp alltraps
8010685d:	e9 35 f7 ff ff       	jmp    80105f97 <alltraps>

80106862 <vector51>:
.globl vector51
vector51:
  pushl $0
80106862:	6a 00                	push   $0x0
  pushl $51
80106864:	6a 33                	push   $0x33
  jmp alltraps
80106866:	e9 2c f7 ff ff       	jmp    80105f97 <alltraps>

8010686b <vector52>:
.globl vector52
vector52:
  pushl $0
8010686b:	6a 00                	push   $0x0
  pushl $52
8010686d:	6a 34                	push   $0x34
  jmp alltraps
8010686f:	e9 23 f7 ff ff       	jmp    80105f97 <alltraps>

80106874 <vector53>:
.globl vector53
vector53:
  pushl $0
80106874:	6a 00                	push   $0x0
  pushl $53
80106876:	6a 35                	push   $0x35
  jmp alltraps
80106878:	e9 1a f7 ff ff       	jmp    80105f97 <alltraps>

8010687d <vector54>:
.globl vector54
vector54:
  pushl $0
8010687d:	6a 00                	push   $0x0
  pushl $54
8010687f:	6a 36                	push   $0x36
  jmp alltraps
80106881:	e9 11 f7 ff ff       	jmp    80105f97 <alltraps>

80106886 <vector55>:
.globl vector55
vector55:
  pushl $0
80106886:	6a 00                	push   $0x0
  pushl $55
80106888:	6a 37                	push   $0x37
  jmp alltraps
8010688a:	e9 08 f7 ff ff       	jmp    80105f97 <alltraps>

8010688f <vector56>:
.globl vector56
vector56:
  pushl $0
8010688f:	6a 00                	push   $0x0
  pushl $56
80106891:	6a 38                	push   $0x38
  jmp alltraps
80106893:	e9 ff f6 ff ff       	jmp    80105f97 <alltraps>

80106898 <vector57>:
.globl vector57
vector57:
  pushl $0
80106898:	6a 00                	push   $0x0
  pushl $57
8010689a:	6a 39                	push   $0x39
  jmp alltraps
8010689c:	e9 f6 f6 ff ff       	jmp    80105f97 <alltraps>

801068a1 <vector58>:
.globl vector58
vector58:
  pushl $0
801068a1:	6a 00                	push   $0x0
  pushl $58
801068a3:	6a 3a                	push   $0x3a
  jmp alltraps
801068a5:	e9 ed f6 ff ff       	jmp    80105f97 <alltraps>

801068aa <vector59>:
.globl vector59
vector59:
  pushl $0
801068aa:	6a 00                	push   $0x0
  pushl $59
801068ac:	6a 3b                	push   $0x3b
  jmp alltraps
801068ae:	e9 e4 f6 ff ff       	jmp    80105f97 <alltraps>

801068b3 <vector60>:
.globl vector60
vector60:
  pushl $0
801068b3:	6a 00                	push   $0x0
  pushl $60
801068b5:	6a 3c                	push   $0x3c
  jmp alltraps
801068b7:	e9 db f6 ff ff       	jmp    80105f97 <alltraps>

801068bc <vector61>:
.globl vector61
vector61:
  pushl $0
801068bc:	6a 00                	push   $0x0
  pushl $61
801068be:	6a 3d                	push   $0x3d
  jmp alltraps
801068c0:	e9 d2 f6 ff ff       	jmp    80105f97 <alltraps>

801068c5 <vector62>:
.globl vector62
vector62:
  pushl $0
801068c5:	6a 00                	push   $0x0
  pushl $62
801068c7:	6a 3e                	push   $0x3e
  jmp alltraps
801068c9:	e9 c9 f6 ff ff       	jmp    80105f97 <alltraps>

801068ce <vector63>:
.globl vector63
vector63:
  pushl $0
801068ce:	6a 00                	push   $0x0
  pushl $63
801068d0:	6a 3f                	push   $0x3f
  jmp alltraps
801068d2:	e9 c0 f6 ff ff       	jmp    80105f97 <alltraps>

801068d7 <vector64>:
.globl vector64
vector64:
  pushl $0
801068d7:	6a 00                	push   $0x0
  pushl $64
801068d9:	6a 40                	push   $0x40
  jmp alltraps
801068db:	e9 b7 f6 ff ff       	jmp    80105f97 <alltraps>

801068e0 <vector65>:
.globl vector65
vector65:
  pushl $0
801068e0:	6a 00                	push   $0x0
  pushl $65
801068e2:	6a 41                	push   $0x41
  jmp alltraps
801068e4:	e9 ae f6 ff ff       	jmp    80105f97 <alltraps>

801068e9 <vector66>:
.globl vector66
vector66:
  pushl $0
801068e9:	6a 00                	push   $0x0
  pushl $66
801068eb:	6a 42                	push   $0x42
  jmp alltraps
801068ed:	e9 a5 f6 ff ff       	jmp    80105f97 <alltraps>

801068f2 <vector67>:
.globl vector67
vector67:
  pushl $0
801068f2:	6a 00                	push   $0x0
  pushl $67
801068f4:	6a 43                	push   $0x43
  jmp alltraps
801068f6:	e9 9c f6 ff ff       	jmp    80105f97 <alltraps>

801068fb <vector68>:
.globl vector68
vector68:
  pushl $0
801068fb:	6a 00                	push   $0x0
  pushl $68
801068fd:	6a 44                	push   $0x44
  jmp alltraps
801068ff:	e9 93 f6 ff ff       	jmp    80105f97 <alltraps>

80106904 <vector69>:
.globl vector69
vector69:
  pushl $0
80106904:	6a 00                	push   $0x0
  pushl $69
80106906:	6a 45                	push   $0x45
  jmp alltraps
80106908:	e9 8a f6 ff ff       	jmp    80105f97 <alltraps>

8010690d <vector70>:
.globl vector70
vector70:
  pushl $0
8010690d:	6a 00                	push   $0x0
  pushl $70
8010690f:	6a 46                	push   $0x46
  jmp alltraps
80106911:	e9 81 f6 ff ff       	jmp    80105f97 <alltraps>

80106916 <vector71>:
.globl vector71
vector71:
  pushl $0
80106916:	6a 00                	push   $0x0
  pushl $71
80106918:	6a 47                	push   $0x47
  jmp alltraps
8010691a:	e9 78 f6 ff ff       	jmp    80105f97 <alltraps>

8010691f <vector72>:
.globl vector72
vector72:
  pushl $0
8010691f:	6a 00                	push   $0x0
  pushl $72
80106921:	6a 48                	push   $0x48
  jmp alltraps
80106923:	e9 6f f6 ff ff       	jmp    80105f97 <alltraps>

80106928 <vector73>:
.globl vector73
vector73:
  pushl $0
80106928:	6a 00                	push   $0x0
  pushl $73
8010692a:	6a 49                	push   $0x49
  jmp alltraps
8010692c:	e9 66 f6 ff ff       	jmp    80105f97 <alltraps>

80106931 <vector74>:
.globl vector74
vector74:
  pushl $0
80106931:	6a 00                	push   $0x0
  pushl $74
80106933:	6a 4a                	push   $0x4a
  jmp alltraps
80106935:	e9 5d f6 ff ff       	jmp    80105f97 <alltraps>

8010693a <vector75>:
.globl vector75
vector75:
  pushl $0
8010693a:	6a 00                	push   $0x0
  pushl $75
8010693c:	6a 4b                	push   $0x4b
  jmp alltraps
8010693e:	e9 54 f6 ff ff       	jmp    80105f97 <alltraps>

80106943 <vector76>:
.globl vector76
vector76:
  pushl $0
80106943:	6a 00                	push   $0x0
  pushl $76
80106945:	6a 4c                	push   $0x4c
  jmp alltraps
80106947:	e9 4b f6 ff ff       	jmp    80105f97 <alltraps>

8010694c <vector77>:
.globl vector77
vector77:
  pushl $0
8010694c:	6a 00                	push   $0x0
  pushl $77
8010694e:	6a 4d                	push   $0x4d
  jmp alltraps
80106950:	e9 42 f6 ff ff       	jmp    80105f97 <alltraps>

80106955 <vector78>:
.globl vector78
vector78:
  pushl $0
80106955:	6a 00                	push   $0x0
  pushl $78
80106957:	6a 4e                	push   $0x4e
  jmp alltraps
80106959:	e9 39 f6 ff ff       	jmp    80105f97 <alltraps>

8010695e <vector79>:
.globl vector79
vector79:
  pushl $0
8010695e:	6a 00                	push   $0x0
  pushl $79
80106960:	6a 4f                	push   $0x4f
  jmp alltraps
80106962:	e9 30 f6 ff ff       	jmp    80105f97 <alltraps>

80106967 <vector80>:
.globl vector80
vector80:
  pushl $0
80106967:	6a 00                	push   $0x0
  pushl $80
80106969:	6a 50                	push   $0x50
  jmp alltraps
8010696b:	e9 27 f6 ff ff       	jmp    80105f97 <alltraps>

80106970 <vector81>:
.globl vector81
vector81:
  pushl $0
80106970:	6a 00                	push   $0x0
  pushl $81
80106972:	6a 51                	push   $0x51
  jmp alltraps
80106974:	e9 1e f6 ff ff       	jmp    80105f97 <alltraps>

80106979 <vector82>:
.globl vector82
vector82:
  pushl $0
80106979:	6a 00                	push   $0x0
  pushl $82
8010697b:	6a 52                	push   $0x52
  jmp alltraps
8010697d:	e9 15 f6 ff ff       	jmp    80105f97 <alltraps>

80106982 <vector83>:
.globl vector83
vector83:
  pushl $0
80106982:	6a 00                	push   $0x0
  pushl $83
80106984:	6a 53                	push   $0x53
  jmp alltraps
80106986:	e9 0c f6 ff ff       	jmp    80105f97 <alltraps>

8010698b <vector84>:
.globl vector84
vector84:
  pushl $0
8010698b:	6a 00                	push   $0x0
  pushl $84
8010698d:	6a 54                	push   $0x54
  jmp alltraps
8010698f:	e9 03 f6 ff ff       	jmp    80105f97 <alltraps>

80106994 <vector85>:
.globl vector85
vector85:
  pushl $0
80106994:	6a 00                	push   $0x0
  pushl $85
80106996:	6a 55                	push   $0x55
  jmp alltraps
80106998:	e9 fa f5 ff ff       	jmp    80105f97 <alltraps>

8010699d <vector86>:
.globl vector86
vector86:
  pushl $0
8010699d:	6a 00                	push   $0x0
  pushl $86
8010699f:	6a 56                	push   $0x56
  jmp alltraps
801069a1:	e9 f1 f5 ff ff       	jmp    80105f97 <alltraps>

801069a6 <vector87>:
.globl vector87
vector87:
  pushl $0
801069a6:	6a 00                	push   $0x0
  pushl $87
801069a8:	6a 57                	push   $0x57
  jmp alltraps
801069aa:	e9 e8 f5 ff ff       	jmp    80105f97 <alltraps>

801069af <vector88>:
.globl vector88
vector88:
  pushl $0
801069af:	6a 00                	push   $0x0
  pushl $88
801069b1:	6a 58                	push   $0x58
  jmp alltraps
801069b3:	e9 df f5 ff ff       	jmp    80105f97 <alltraps>

801069b8 <vector89>:
.globl vector89
vector89:
  pushl $0
801069b8:	6a 00                	push   $0x0
  pushl $89
801069ba:	6a 59                	push   $0x59
  jmp alltraps
801069bc:	e9 d6 f5 ff ff       	jmp    80105f97 <alltraps>

801069c1 <vector90>:
.globl vector90
vector90:
  pushl $0
801069c1:	6a 00                	push   $0x0
  pushl $90
801069c3:	6a 5a                	push   $0x5a
  jmp alltraps
801069c5:	e9 cd f5 ff ff       	jmp    80105f97 <alltraps>

801069ca <vector91>:
.globl vector91
vector91:
  pushl $0
801069ca:	6a 00                	push   $0x0
  pushl $91
801069cc:	6a 5b                	push   $0x5b
  jmp alltraps
801069ce:	e9 c4 f5 ff ff       	jmp    80105f97 <alltraps>

801069d3 <vector92>:
.globl vector92
vector92:
  pushl $0
801069d3:	6a 00                	push   $0x0
  pushl $92
801069d5:	6a 5c                	push   $0x5c
  jmp alltraps
801069d7:	e9 bb f5 ff ff       	jmp    80105f97 <alltraps>

801069dc <vector93>:
.globl vector93
vector93:
  pushl $0
801069dc:	6a 00                	push   $0x0
  pushl $93
801069de:	6a 5d                	push   $0x5d
  jmp alltraps
801069e0:	e9 b2 f5 ff ff       	jmp    80105f97 <alltraps>

801069e5 <vector94>:
.globl vector94
vector94:
  pushl $0
801069e5:	6a 00                	push   $0x0
  pushl $94
801069e7:	6a 5e                	push   $0x5e
  jmp alltraps
801069e9:	e9 a9 f5 ff ff       	jmp    80105f97 <alltraps>

801069ee <vector95>:
.globl vector95
vector95:
  pushl $0
801069ee:	6a 00                	push   $0x0
  pushl $95
801069f0:	6a 5f                	push   $0x5f
  jmp alltraps
801069f2:	e9 a0 f5 ff ff       	jmp    80105f97 <alltraps>

801069f7 <vector96>:
.globl vector96
vector96:
  pushl $0
801069f7:	6a 00                	push   $0x0
  pushl $96
801069f9:	6a 60                	push   $0x60
  jmp alltraps
801069fb:	e9 97 f5 ff ff       	jmp    80105f97 <alltraps>

80106a00 <vector97>:
.globl vector97
vector97:
  pushl $0
80106a00:	6a 00                	push   $0x0
  pushl $97
80106a02:	6a 61                	push   $0x61
  jmp alltraps
80106a04:	e9 8e f5 ff ff       	jmp    80105f97 <alltraps>

80106a09 <vector98>:
.globl vector98
vector98:
  pushl $0
80106a09:	6a 00                	push   $0x0
  pushl $98
80106a0b:	6a 62                	push   $0x62
  jmp alltraps
80106a0d:	e9 85 f5 ff ff       	jmp    80105f97 <alltraps>

80106a12 <vector99>:
.globl vector99
vector99:
  pushl $0
80106a12:	6a 00                	push   $0x0
  pushl $99
80106a14:	6a 63                	push   $0x63
  jmp alltraps
80106a16:	e9 7c f5 ff ff       	jmp    80105f97 <alltraps>

80106a1b <vector100>:
.globl vector100
vector100:
  pushl $0
80106a1b:	6a 00                	push   $0x0
  pushl $100
80106a1d:	6a 64                	push   $0x64
  jmp alltraps
80106a1f:	e9 73 f5 ff ff       	jmp    80105f97 <alltraps>

80106a24 <vector101>:
.globl vector101
vector101:
  pushl $0
80106a24:	6a 00                	push   $0x0
  pushl $101
80106a26:	6a 65                	push   $0x65
  jmp alltraps
80106a28:	e9 6a f5 ff ff       	jmp    80105f97 <alltraps>

80106a2d <vector102>:
.globl vector102
vector102:
  pushl $0
80106a2d:	6a 00                	push   $0x0
  pushl $102
80106a2f:	6a 66                	push   $0x66
  jmp alltraps
80106a31:	e9 61 f5 ff ff       	jmp    80105f97 <alltraps>

80106a36 <vector103>:
.globl vector103
vector103:
  pushl $0
80106a36:	6a 00                	push   $0x0
  pushl $103
80106a38:	6a 67                	push   $0x67
  jmp alltraps
80106a3a:	e9 58 f5 ff ff       	jmp    80105f97 <alltraps>

80106a3f <vector104>:
.globl vector104
vector104:
  pushl $0
80106a3f:	6a 00                	push   $0x0
  pushl $104
80106a41:	6a 68                	push   $0x68
  jmp alltraps
80106a43:	e9 4f f5 ff ff       	jmp    80105f97 <alltraps>

80106a48 <vector105>:
.globl vector105
vector105:
  pushl $0
80106a48:	6a 00                	push   $0x0
  pushl $105
80106a4a:	6a 69                	push   $0x69
  jmp alltraps
80106a4c:	e9 46 f5 ff ff       	jmp    80105f97 <alltraps>

80106a51 <vector106>:
.globl vector106
vector106:
  pushl $0
80106a51:	6a 00                	push   $0x0
  pushl $106
80106a53:	6a 6a                	push   $0x6a
  jmp alltraps
80106a55:	e9 3d f5 ff ff       	jmp    80105f97 <alltraps>

80106a5a <vector107>:
.globl vector107
vector107:
  pushl $0
80106a5a:	6a 00                	push   $0x0
  pushl $107
80106a5c:	6a 6b                	push   $0x6b
  jmp alltraps
80106a5e:	e9 34 f5 ff ff       	jmp    80105f97 <alltraps>

80106a63 <vector108>:
.globl vector108
vector108:
  pushl $0
80106a63:	6a 00                	push   $0x0
  pushl $108
80106a65:	6a 6c                	push   $0x6c
  jmp alltraps
80106a67:	e9 2b f5 ff ff       	jmp    80105f97 <alltraps>

80106a6c <vector109>:
.globl vector109
vector109:
  pushl $0
80106a6c:	6a 00                	push   $0x0
  pushl $109
80106a6e:	6a 6d                	push   $0x6d
  jmp alltraps
80106a70:	e9 22 f5 ff ff       	jmp    80105f97 <alltraps>

80106a75 <vector110>:
.globl vector110
vector110:
  pushl $0
80106a75:	6a 00                	push   $0x0
  pushl $110
80106a77:	6a 6e                	push   $0x6e
  jmp alltraps
80106a79:	e9 19 f5 ff ff       	jmp    80105f97 <alltraps>

80106a7e <vector111>:
.globl vector111
vector111:
  pushl $0
80106a7e:	6a 00                	push   $0x0
  pushl $111
80106a80:	6a 6f                	push   $0x6f
  jmp alltraps
80106a82:	e9 10 f5 ff ff       	jmp    80105f97 <alltraps>

80106a87 <vector112>:
.globl vector112
vector112:
  pushl $0
80106a87:	6a 00                	push   $0x0
  pushl $112
80106a89:	6a 70                	push   $0x70
  jmp alltraps
80106a8b:	e9 07 f5 ff ff       	jmp    80105f97 <alltraps>

80106a90 <vector113>:
.globl vector113
vector113:
  pushl $0
80106a90:	6a 00                	push   $0x0
  pushl $113
80106a92:	6a 71                	push   $0x71
  jmp alltraps
80106a94:	e9 fe f4 ff ff       	jmp    80105f97 <alltraps>

80106a99 <vector114>:
.globl vector114
vector114:
  pushl $0
80106a99:	6a 00                	push   $0x0
  pushl $114
80106a9b:	6a 72                	push   $0x72
  jmp alltraps
80106a9d:	e9 f5 f4 ff ff       	jmp    80105f97 <alltraps>

80106aa2 <vector115>:
.globl vector115
vector115:
  pushl $0
80106aa2:	6a 00                	push   $0x0
  pushl $115
80106aa4:	6a 73                	push   $0x73
  jmp alltraps
80106aa6:	e9 ec f4 ff ff       	jmp    80105f97 <alltraps>

80106aab <vector116>:
.globl vector116
vector116:
  pushl $0
80106aab:	6a 00                	push   $0x0
  pushl $116
80106aad:	6a 74                	push   $0x74
  jmp alltraps
80106aaf:	e9 e3 f4 ff ff       	jmp    80105f97 <alltraps>

80106ab4 <vector117>:
.globl vector117
vector117:
  pushl $0
80106ab4:	6a 00                	push   $0x0
  pushl $117
80106ab6:	6a 75                	push   $0x75
  jmp alltraps
80106ab8:	e9 da f4 ff ff       	jmp    80105f97 <alltraps>

80106abd <vector118>:
.globl vector118
vector118:
  pushl $0
80106abd:	6a 00                	push   $0x0
  pushl $118
80106abf:	6a 76                	push   $0x76
  jmp alltraps
80106ac1:	e9 d1 f4 ff ff       	jmp    80105f97 <alltraps>

80106ac6 <vector119>:
.globl vector119
vector119:
  pushl $0
80106ac6:	6a 00                	push   $0x0
  pushl $119
80106ac8:	6a 77                	push   $0x77
  jmp alltraps
80106aca:	e9 c8 f4 ff ff       	jmp    80105f97 <alltraps>

80106acf <vector120>:
.globl vector120
vector120:
  pushl $0
80106acf:	6a 00                	push   $0x0
  pushl $120
80106ad1:	6a 78                	push   $0x78
  jmp alltraps
80106ad3:	e9 bf f4 ff ff       	jmp    80105f97 <alltraps>

80106ad8 <vector121>:
.globl vector121
vector121:
  pushl $0
80106ad8:	6a 00                	push   $0x0
  pushl $121
80106ada:	6a 79                	push   $0x79
  jmp alltraps
80106adc:	e9 b6 f4 ff ff       	jmp    80105f97 <alltraps>

80106ae1 <vector122>:
.globl vector122
vector122:
  pushl $0
80106ae1:	6a 00                	push   $0x0
  pushl $122
80106ae3:	6a 7a                	push   $0x7a
  jmp alltraps
80106ae5:	e9 ad f4 ff ff       	jmp    80105f97 <alltraps>

80106aea <vector123>:
.globl vector123
vector123:
  pushl $0
80106aea:	6a 00                	push   $0x0
  pushl $123
80106aec:	6a 7b                	push   $0x7b
  jmp alltraps
80106aee:	e9 a4 f4 ff ff       	jmp    80105f97 <alltraps>

80106af3 <vector124>:
.globl vector124
vector124:
  pushl $0
80106af3:	6a 00                	push   $0x0
  pushl $124
80106af5:	6a 7c                	push   $0x7c
  jmp alltraps
80106af7:	e9 9b f4 ff ff       	jmp    80105f97 <alltraps>

80106afc <vector125>:
.globl vector125
vector125:
  pushl $0
80106afc:	6a 00                	push   $0x0
  pushl $125
80106afe:	6a 7d                	push   $0x7d
  jmp alltraps
80106b00:	e9 92 f4 ff ff       	jmp    80105f97 <alltraps>

80106b05 <vector126>:
.globl vector126
vector126:
  pushl $0
80106b05:	6a 00                	push   $0x0
  pushl $126
80106b07:	6a 7e                	push   $0x7e
  jmp alltraps
80106b09:	e9 89 f4 ff ff       	jmp    80105f97 <alltraps>

80106b0e <vector127>:
.globl vector127
vector127:
  pushl $0
80106b0e:	6a 00                	push   $0x0
  pushl $127
80106b10:	6a 7f                	push   $0x7f
  jmp alltraps
80106b12:	e9 80 f4 ff ff       	jmp    80105f97 <alltraps>

80106b17 <vector128>:
.globl vector128
vector128:
  pushl $0
80106b17:	6a 00                	push   $0x0
  pushl $128
80106b19:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80106b1e:	e9 74 f4 ff ff       	jmp    80105f97 <alltraps>

80106b23 <vector129>:
.globl vector129
vector129:
  pushl $0
80106b23:	6a 00                	push   $0x0
  pushl $129
80106b25:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80106b2a:	e9 68 f4 ff ff       	jmp    80105f97 <alltraps>

80106b2f <vector130>:
.globl vector130
vector130:
  pushl $0
80106b2f:	6a 00                	push   $0x0
  pushl $130
80106b31:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80106b36:	e9 5c f4 ff ff       	jmp    80105f97 <alltraps>

80106b3b <vector131>:
.globl vector131
vector131:
  pushl $0
80106b3b:	6a 00                	push   $0x0
  pushl $131
80106b3d:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80106b42:	e9 50 f4 ff ff       	jmp    80105f97 <alltraps>

80106b47 <vector132>:
.globl vector132
vector132:
  pushl $0
80106b47:	6a 00                	push   $0x0
  pushl $132
80106b49:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80106b4e:	e9 44 f4 ff ff       	jmp    80105f97 <alltraps>

80106b53 <vector133>:
.globl vector133
vector133:
  pushl $0
80106b53:	6a 00                	push   $0x0
  pushl $133
80106b55:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80106b5a:	e9 38 f4 ff ff       	jmp    80105f97 <alltraps>

80106b5f <vector134>:
.globl vector134
vector134:
  pushl $0
80106b5f:	6a 00                	push   $0x0
  pushl $134
80106b61:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80106b66:	e9 2c f4 ff ff       	jmp    80105f97 <alltraps>

80106b6b <vector135>:
.globl vector135
vector135:
  pushl $0
80106b6b:	6a 00                	push   $0x0
  pushl $135
80106b6d:	68 87 00 00 00       	push   $0x87
  jmp alltraps
80106b72:	e9 20 f4 ff ff       	jmp    80105f97 <alltraps>

80106b77 <vector136>:
.globl vector136
vector136:
  pushl $0
80106b77:	6a 00                	push   $0x0
  pushl $136
80106b79:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80106b7e:	e9 14 f4 ff ff       	jmp    80105f97 <alltraps>

80106b83 <vector137>:
.globl vector137
vector137:
  pushl $0
80106b83:	6a 00                	push   $0x0
  pushl $137
80106b85:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80106b8a:	e9 08 f4 ff ff       	jmp    80105f97 <alltraps>

80106b8f <vector138>:
.globl vector138
vector138:
  pushl $0
80106b8f:	6a 00                	push   $0x0
  pushl $138
80106b91:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80106b96:	e9 fc f3 ff ff       	jmp    80105f97 <alltraps>

80106b9b <vector139>:
.globl vector139
vector139:
  pushl $0
80106b9b:	6a 00                	push   $0x0
  pushl $139
80106b9d:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80106ba2:	e9 f0 f3 ff ff       	jmp    80105f97 <alltraps>

80106ba7 <vector140>:
.globl vector140
vector140:
  pushl $0
80106ba7:	6a 00                	push   $0x0
  pushl $140
80106ba9:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80106bae:	e9 e4 f3 ff ff       	jmp    80105f97 <alltraps>

80106bb3 <vector141>:
.globl vector141
vector141:
  pushl $0
80106bb3:	6a 00                	push   $0x0
  pushl $141
80106bb5:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80106bba:	e9 d8 f3 ff ff       	jmp    80105f97 <alltraps>

80106bbf <vector142>:
.globl vector142
vector142:
  pushl $0
80106bbf:	6a 00                	push   $0x0
  pushl $142
80106bc1:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80106bc6:	e9 cc f3 ff ff       	jmp    80105f97 <alltraps>

80106bcb <vector143>:
.globl vector143
vector143:
  pushl $0
80106bcb:	6a 00                	push   $0x0
  pushl $143
80106bcd:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80106bd2:	e9 c0 f3 ff ff       	jmp    80105f97 <alltraps>

80106bd7 <vector144>:
.globl vector144
vector144:
  pushl $0
80106bd7:	6a 00                	push   $0x0
  pushl $144
80106bd9:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80106bde:	e9 b4 f3 ff ff       	jmp    80105f97 <alltraps>

80106be3 <vector145>:
.globl vector145
vector145:
  pushl $0
80106be3:	6a 00                	push   $0x0
  pushl $145
80106be5:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80106bea:	e9 a8 f3 ff ff       	jmp    80105f97 <alltraps>

80106bef <vector146>:
.globl vector146
vector146:
  pushl $0
80106bef:	6a 00                	push   $0x0
  pushl $146
80106bf1:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80106bf6:	e9 9c f3 ff ff       	jmp    80105f97 <alltraps>

80106bfb <vector147>:
.globl vector147
vector147:
  pushl $0
80106bfb:	6a 00                	push   $0x0
  pushl $147
80106bfd:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80106c02:	e9 90 f3 ff ff       	jmp    80105f97 <alltraps>

80106c07 <vector148>:
.globl vector148
vector148:
  pushl $0
80106c07:	6a 00                	push   $0x0
  pushl $148
80106c09:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80106c0e:	e9 84 f3 ff ff       	jmp    80105f97 <alltraps>

80106c13 <vector149>:
.globl vector149
vector149:
  pushl $0
80106c13:	6a 00                	push   $0x0
  pushl $149
80106c15:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80106c1a:	e9 78 f3 ff ff       	jmp    80105f97 <alltraps>

80106c1f <vector150>:
.globl vector150
vector150:
  pushl $0
80106c1f:	6a 00                	push   $0x0
  pushl $150
80106c21:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80106c26:	e9 6c f3 ff ff       	jmp    80105f97 <alltraps>

80106c2b <vector151>:
.globl vector151
vector151:
  pushl $0
80106c2b:	6a 00                	push   $0x0
  pushl $151
80106c2d:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80106c32:	e9 60 f3 ff ff       	jmp    80105f97 <alltraps>

80106c37 <vector152>:
.globl vector152
vector152:
  pushl $0
80106c37:	6a 00                	push   $0x0
  pushl $152
80106c39:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80106c3e:	e9 54 f3 ff ff       	jmp    80105f97 <alltraps>

80106c43 <vector153>:
.globl vector153
vector153:
  pushl $0
80106c43:	6a 00                	push   $0x0
  pushl $153
80106c45:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80106c4a:	e9 48 f3 ff ff       	jmp    80105f97 <alltraps>

80106c4f <vector154>:
.globl vector154
vector154:
  pushl $0
80106c4f:	6a 00                	push   $0x0
  pushl $154
80106c51:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80106c56:	e9 3c f3 ff ff       	jmp    80105f97 <alltraps>

80106c5b <vector155>:
.globl vector155
vector155:
  pushl $0
80106c5b:	6a 00                	push   $0x0
  pushl $155
80106c5d:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80106c62:	e9 30 f3 ff ff       	jmp    80105f97 <alltraps>

80106c67 <vector156>:
.globl vector156
vector156:
  pushl $0
80106c67:	6a 00                	push   $0x0
  pushl $156
80106c69:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80106c6e:	e9 24 f3 ff ff       	jmp    80105f97 <alltraps>

80106c73 <vector157>:
.globl vector157
vector157:
  pushl $0
80106c73:	6a 00                	push   $0x0
  pushl $157
80106c75:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80106c7a:	e9 18 f3 ff ff       	jmp    80105f97 <alltraps>

80106c7f <vector158>:
.globl vector158
vector158:
  pushl $0
80106c7f:	6a 00                	push   $0x0
  pushl $158
80106c81:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80106c86:	e9 0c f3 ff ff       	jmp    80105f97 <alltraps>

80106c8b <vector159>:
.globl vector159
vector159:
  pushl $0
80106c8b:	6a 00                	push   $0x0
  pushl $159
80106c8d:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80106c92:	e9 00 f3 ff ff       	jmp    80105f97 <alltraps>

80106c97 <vector160>:
.globl vector160
vector160:
  pushl $0
80106c97:	6a 00                	push   $0x0
  pushl $160
80106c99:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80106c9e:	e9 f4 f2 ff ff       	jmp    80105f97 <alltraps>

80106ca3 <vector161>:
.globl vector161
vector161:
  pushl $0
80106ca3:	6a 00                	push   $0x0
  pushl $161
80106ca5:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80106caa:	e9 e8 f2 ff ff       	jmp    80105f97 <alltraps>

80106caf <vector162>:
.globl vector162
vector162:
  pushl $0
80106caf:	6a 00                	push   $0x0
  pushl $162
80106cb1:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80106cb6:	e9 dc f2 ff ff       	jmp    80105f97 <alltraps>

80106cbb <vector163>:
.globl vector163
vector163:
  pushl $0
80106cbb:	6a 00                	push   $0x0
  pushl $163
80106cbd:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80106cc2:	e9 d0 f2 ff ff       	jmp    80105f97 <alltraps>

80106cc7 <vector164>:
.globl vector164
vector164:
  pushl $0
80106cc7:	6a 00                	push   $0x0
  pushl $164
80106cc9:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80106cce:	e9 c4 f2 ff ff       	jmp    80105f97 <alltraps>

80106cd3 <vector165>:
.globl vector165
vector165:
  pushl $0
80106cd3:	6a 00                	push   $0x0
  pushl $165
80106cd5:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80106cda:	e9 b8 f2 ff ff       	jmp    80105f97 <alltraps>

80106cdf <vector166>:
.globl vector166
vector166:
  pushl $0
80106cdf:	6a 00                	push   $0x0
  pushl $166
80106ce1:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80106ce6:	e9 ac f2 ff ff       	jmp    80105f97 <alltraps>

80106ceb <vector167>:
.globl vector167
vector167:
  pushl $0
80106ceb:	6a 00                	push   $0x0
  pushl $167
80106ced:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80106cf2:	e9 a0 f2 ff ff       	jmp    80105f97 <alltraps>

80106cf7 <vector168>:
.globl vector168
vector168:
  pushl $0
80106cf7:	6a 00                	push   $0x0
  pushl $168
80106cf9:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80106cfe:	e9 94 f2 ff ff       	jmp    80105f97 <alltraps>

80106d03 <vector169>:
.globl vector169
vector169:
  pushl $0
80106d03:	6a 00                	push   $0x0
  pushl $169
80106d05:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80106d0a:	e9 88 f2 ff ff       	jmp    80105f97 <alltraps>

80106d0f <vector170>:
.globl vector170
vector170:
  pushl $0
80106d0f:	6a 00                	push   $0x0
  pushl $170
80106d11:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80106d16:	e9 7c f2 ff ff       	jmp    80105f97 <alltraps>

80106d1b <vector171>:
.globl vector171
vector171:
  pushl $0
80106d1b:	6a 00                	push   $0x0
  pushl $171
80106d1d:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80106d22:	e9 70 f2 ff ff       	jmp    80105f97 <alltraps>

80106d27 <vector172>:
.globl vector172
vector172:
  pushl $0
80106d27:	6a 00                	push   $0x0
  pushl $172
80106d29:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80106d2e:	e9 64 f2 ff ff       	jmp    80105f97 <alltraps>

80106d33 <vector173>:
.globl vector173
vector173:
  pushl $0
80106d33:	6a 00                	push   $0x0
  pushl $173
80106d35:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80106d3a:	e9 58 f2 ff ff       	jmp    80105f97 <alltraps>

80106d3f <vector174>:
.globl vector174
vector174:
  pushl $0
80106d3f:	6a 00                	push   $0x0
  pushl $174
80106d41:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80106d46:	e9 4c f2 ff ff       	jmp    80105f97 <alltraps>

80106d4b <vector175>:
.globl vector175
vector175:
  pushl $0
80106d4b:	6a 00                	push   $0x0
  pushl $175
80106d4d:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80106d52:	e9 40 f2 ff ff       	jmp    80105f97 <alltraps>

80106d57 <vector176>:
.globl vector176
vector176:
  pushl $0
80106d57:	6a 00                	push   $0x0
  pushl $176
80106d59:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80106d5e:	e9 34 f2 ff ff       	jmp    80105f97 <alltraps>

80106d63 <vector177>:
.globl vector177
vector177:
  pushl $0
80106d63:	6a 00                	push   $0x0
  pushl $177
80106d65:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80106d6a:	e9 28 f2 ff ff       	jmp    80105f97 <alltraps>

80106d6f <vector178>:
.globl vector178
vector178:
  pushl $0
80106d6f:	6a 00                	push   $0x0
  pushl $178
80106d71:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80106d76:	e9 1c f2 ff ff       	jmp    80105f97 <alltraps>

80106d7b <vector179>:
.globl vector179
vector179:
  pushl $0
80106d7b:	6a 00                	push   $0x0
  pushl $179
80106d7d:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80106d82:	e9 10 f2 ff ff       	jmp    80105f97 <alltraps>

80106d87 <vector180>:
.globl vector180
vector180:
  pushl $0
80106d87:	6a 00                	push   $0x0
  pushl $180
80106d89:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80106d8e:	e9 04 f2 ff ff       	jmp    80105f97 <alltraps>

80106d93 <vector181>:
.globl vector181
vector181:
  pushl $0
80106d93:	6a 00                	push   $0x0
  pushl $181
80106d95:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80106d9a:	e9 f8 f1 ff ff       	jmp    80105f97 <alltraps>

80106d9f <vector182>:
.globl vector182
vector182:
  pushl $0
80106d9f:	6a 00                	push   $0x0
  pushl $182
80106da1:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80106da6:	e9 ec f1 ff ff       	jmp    80105f97 <alltraps>

80106dab <vector183>:
.globl vector183
vector183:
  pushl $0
80106dab:	6a 00                	push   $0x0
  pushl $183
80106dad:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80106db2:	e9 e0 f1 ff ff       	jmp    80105f97 <alltraps>

80106db7 <vector184>:
.globl vector184
vector184:
  pushl $0
80106db7:	6a 00                	push   $0x0
  pushl $184
80106db9:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80106dbe:	e9 d4 f1 ff ff       	jmp    80105f97 <alltraps>

80106dc3 <vector185>:
.globl vector185
vector185:
  pushl $0
80106dc3:	6a 00                	push   $0x0
  pushl $185
80106dc5:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80106dca:	e9 c8 f1 ff ff       	jmp    80105f97 <alltraps>

80106dcf <vector186>:
.globl vector186
vector186:
  pushl $0
80106dcf:	6a 00                	push   $0x0
  pushl $186
80106dd1:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80106dd6:	e9 bc f1 ff ff       	jmp    80105f97 <alltraps>

80106ddb <vector187>:
.globl vector187
vector187:
  pushl $0
80106ddb:	6a 00                	push   $0x0
  pushl $187
80106ddd:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80106de2:	e9 b0 f1 ff ff       	jmp    80105f97 <alltraps>

80106de7 <vector188>:
.globl vector188
vector188:
  pushl $0
80106de7:	6a 00                	push   $0x0
  pushl $188
80106de9:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80106dee:	e9 a4 f1 ff ff       	jmp    80105f97 <alltraps>

80106df3 <vector189>:
.globl vector189
vector189:
  pushl $0
80106df3:	6a 00                	push   $0x0
  pushl $189
80106df5:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80106dfa:	e9 98 f1 ff ff       	jmp    80105f97 <alltraps>

80106dff <vector190>:
.globl vector190
vector190:
  pushl $0
80106dff:	6a 00                	push   $0x0
  pushl $190
80106e01:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80106e06:	e9 8c f1 ff ff       	jmp    80105f97 <alltraps>

80106e0b <vector191>:
.globl vector191
vector191:
  pushl $0
80106e0b:	6a 00                	push   $0x0
  pushl $191
80106e0d:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80106e12:	e9 80 f1 ff ff       	jmp    80105f97 <alltraps>

80106e17 <vector192>:
.globl vector192
vector192:
  pushl $0
80106e17:	6a 00                	push   $0x0
  pushl $192
80106e19:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80106e1e:	e9 74 f1 ff ff       	jmp    80105f97 <alltraps>

80106e23 <vector193>:
.globl vector193
vector193:
  pushl $0
80106e23:	6a 00                	push   $0x0
  pushl $193
80106e25:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80106e2a:	e9 68 f1 ff ff       	jmp    80105f97 <alltraps>

80106e2f <vector194>:
.globl vector194
vector194:
  pushl $0
80106e2f:	6a 00                	push   $0x0
  pushl $194
80106e31:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80106e36:	e9 5c f1 ff ff       	jmp    80105f97 <alltraps>

80106e3b <vector195>:
.globl vector195
vector195:
  pushl $0
80106e3b:	6a 00                	push   $0x0
  pushl $195
80106e3d:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80106e42:	e9 50 f1 ff ff       	jmp    80105f97 <alltraps>

80106e47 <vector196>:
.globl vector196
vector196:
  pushl $0
80106e47:	6a 00                	push   $0x0
  pushl $196
80106e49:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80106e4e:	e9 44 f1 ff ff       	jmp    80105f97 <alltraps>

80106e53 <vector197>:
.globl vector197
vector197:
  pushl $0
80106e53:	6a 00                	push   $0x0
  pushl $197
80106e55:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80106e5a:	e9 38 f1 ff ff       	jmp    80105f97 <alltraps>

80106e5f <vector198>:
.globl vector198
vector198:
  pushl $0
80106e5f:	6a 00                	push   $0x0
  pushl $198
80106e61:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80106e66:	e9 2c f1 ff ff       	jmp    80105f97 <alltraps>

80106e6b <vector199>:
.globl vector199
vector199:
  pushl $0
80106e6b:	6a 00                	push   $0x0
  pushl $199
80106e6d:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80106e72:	e9 20 f1 ff ff       	jmp    80105f97 <alltraps>

80106e77 <vector200>:
.globl vector200
vector200:
  pushl $0
80106e77:	6a 00                	push   $0x0
  pushl $200
80106e79:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80106e7e:	e9 14 f1 ff ff       	jmp    80105f97 <alltraps>

80106e83 <vector201>:
.globl vector201
vector201:
  pushl $0
80106e83:	6a 00                	push   $0x0
  pushl $201
80106e85:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80106e8a:	e9 08 f1 ff ff       	jmp    80105f97 <alltraps>

80106e8f <vector202>:
.globl vector202
vector202:
  pushl $0
80106e8f:	6a 00                	push   $0x0
  pushl $202
80106e91:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80106e96:	e9 fc f0 ff ff       	jmp    80105f97 <alltraps>

80106e9b <vector203>:
.globl vector203
vector203:
  pushl $0
80106e9b:	6a 00                	push   $0x0
  pushl $203
80106e9d:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80106ea2:	e9 f0 f0 ff ff       	jmp    80105f97 <alltraps>

80106ea7 <vector204>:
.globl vector204
vector204:
  pushl $0
80106ea7:	6a 00                	push   $0x0
  pushl $204
80106ea9:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80106eae:	e9 e4 f0 ff ff       	jmp    80105f97 <alltraps>

80106eb3 <vector205>:
.globl vector205
vector205:
  pushl $0
80106eb3:	6a 00                	push   $0x0
  pushl $205
80106eb5:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80106eba:	e9 d8 f0 ff ff       	jmp    80105f97 <alltraps>

80106ebf <vector206>:
.globl vector206
vector206:
  pushl $0
80106ebf:	6a 00                	push   $0x0
  pushl $206
80106ec1:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80106ec6:	e9 cc f0 ff ff       	jmp    80105f97 <alltraps>

80106ecb <vector207>:
.globl vector207
vector207:
  pushl $0
80106ecb:	6a 00                	push   $0x0
  pushl $207
80106ecd:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80106ed2:	e9 c0 f0 ff ff       	jmp    80105f97 <alltraps>

80106ed7 <vector208>:
.globl vector208
vector208:
  pushl $0
80106ed7:	6a 00                	push   $0x0
  pushl $208
80106ed9:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80106ede:	e9 b4 f0 ff ff       	jmp    80105f97 <alltraps>

80106ee3 <vector209>:
.globl vector209
vector209:
  pushl $0
80106ee3:	6a 00                	push   $0x0
  pushl $209
80106ee5:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80106eea:	e9 a8 f0 ff ff       	jmp    80105f97 <alltraps>

80106eef <vector210>:
.globl vector210
vector210:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $210
80106ef1:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80106ef6:	e9 9c f0 ff ff       	jmp    80105f97 <alltraps>

80106efb <vector211>:
.globl vector211
vector211:
  pushl $0
80106efb:	6a 00                	push   $0x0
  pushl $211
80106efd:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80106f02:	e9 90 f0 ff ff       	jmp    80105f97 <alltraps>

80106f07 <vector212>:
.globl vector212
vector212:
  pushl $0
80106f07:	6a 00                	push   $0x0
  pushl $212
80106f09:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80106f0e:	e9 84 f0 ff ff       	jmp    80105f97 <alltraps>

80106f13 <vector213>:
.globl vector213
vector213:
  pushl $0
80106f13:	6a 00                	push   $0x0
  pushl $213
80106f15:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80106f1a:	e9 78 f0 ff ff       	jmp    80105f97 <alltraps>

80106f1f <vector214>:
.globl vector214
vector214:
  pushl $0
80106f1f:	6a 00                	push   $0x0
  pushl $214
80106f21:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80106f26:	e9 6c f0 ff ff       	jmp    80105f97 <alltraps>

80106f2b <vector215>:
.globl vector215
vector215:
  pushl $0
80106f2b:	6a 00                	push   $0x0
  pushl $215
80106f2d:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80106f32:	e9 60 f0 ff ff       	jmp    80105f97 <alltraps>

80106f37 <vector216>:
.globl vector216
vector216:
  pushl $0
80106f37:	6a 00                	push   $0x0
  pushl $216
80106f39:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80106f3e:	e9 54 f0 ff ff       	jmp    80105f97 <alltraps>

80106f43 <vector217>:
.globl vector217
vector217:
  pushl $0
80106f43:	6a 00                	push   $0x0
  pushl $217
80106f45:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80106f4a:	e9 48 f0 ff ff       	jmp    80105f97 <alltraps>

80106f4f <vector218>:
.globl vector218
vector218:
  pushl $0
80106f4f:	6a 00                	push   $0x0
  pushl $218
80106f51:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80106f56:	e9 3c f0 ff ff       	jmp    80105f97 <alltraps>

80106f5b <vector219>:
.globl vector219
vector219:
  pushl $0
80106f5b:	6a 00                	push   $0x0
  pushl $219
80106f5d:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80106f62:	e9 30 f0 ff ff       	jmp    80105f97 <alltraps>

80106f67 <vector220>:
.globl vector220
vector220:
  pushl $0
80106f67:	6a 00                	push   $0x0
  pushl $220
80106f69:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80106f6e:	e9 24 f0 ff ff       	jmp    80105f97 <alltraps>

80106f73 <vector221>:
.globl vector221
vector221:
  pushl $0
80106f73:	6a 00                	push   $0x0
  pushl $221
80106f75:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80106f7a:	e9 18 f0 ff ff       	jmp    80105f97 <alltraps>

80106f7f <vector222>:
.globl vector222
vector222:
  pushl $0
80106f7f:	6a 00                	push   $0x0
  pushl $222
80106f81:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80106f86:	e9 0c f0 ff ff       	jmp    80105f97 <alltraps>

80106f8b <vector223>:
.globl vector223
vector223:
  pushl $0
80106f8b:	6a 00                	push   $0x0
  pushl $223
80106f8d:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80106f92:	e9 00 f0 ff ff       	jmp    80105f97 <alltraps>

80106f97 <vector224>:
.globl vector224
vector224:
  pushl $0
80106f97:	6a 00                	push   $0x0
  pushl $224
80106f99:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80106f9e:	e9 f4 ef ff ff       	jmp    80105f97 <alltraps>

80106fa3 <vector225>:
.globl vector225
vector225:
  pushl $0
80106fa3:	6a 00                	push   $0x0
  pushl $225
80106fa5:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80106faa:	e9 e8 ef ff ff       	jmp    80105f97 <alltraps>

80106faf <vector226>:
.globl vector226
vector226:
  pushl $0
80106faf:	6a 00                	push   $0x0
  pushl $226
80106fb1:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80106fb6:	e9 dc ef ff ff       	jmp    80105f97 <alltraps>

80106fbb <vector227>:
.globl vector227
vector227:
  pushl $0
80106fbb:	6a 00                	push   $0x0
  pushl $227
80106fbd:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80106fc2:	e9 d0 ef ff ff       	jmp    80105f97 <alltraps>

80106fc7 <vector228>:
.globl vector228
vector228:
  pushl $0
80106fc7:	6a 00                	push   $0x0
  pushl $228
80106fc9:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80106fce:	e9 c4 ef ff ff       	jmp    80105f97 <alltraps>

80106fd3 <vector229>:
.globl vector229
vector229:
  pushl $0
80106fd3:	6a 00                	push   $0x0
  pushl $229
80106fd5:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80106fda:	e9 b8 ef ff ff       	jmp    80105f97 <alltraps>

80106fdf <vector230>:
.globl vector230
vector230:
  pushl $0
80106fdf:	6a 00                	push   $0x0
  pushl $230
80106fe1:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80106fe6:	e9 ac ef ff ff       	jmp    80105f97 <alltraps>

80106feb <vector231>:
.globl vector231
vector231:
  pushl $0
80106feb:	6a 00                	push   $0x0
  pushl $231
80106fed:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80106ff2:	e9 a0 ef ff ff       	jmp    80105f97 <alltraps>

80106ff7 <vector232>:
.globl vector232
vector232:
  pushl $0
80106ff7:	6a 00                	push   $0x0
  pushl $232
80106ff9:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80106ffe:	e9 94 ef ff ff       	jmp    80105f97 <alltraps>

80107003 <vector233>:
.globl vector233
vector233:
  pushl $0
80107003:	6a 00                	push   $0x0
  pushl $233
80107005:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
8010700a:	e9 88 ef ff ff       	jmp    80105f97 <alltraps>

8010700f <vector234>:
.globl vector234
vector234:
  pushl $0
8010700f:	6a 00                	push   $0x0
  pushl $234
80107011:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107016:	e9 7c ef ff ff       	jmp    80105f97 <alltraps>

8010701b <vector235>:
.globl vector235
vector235:
  pushl $0
8010701b:	6a 00                	push   $0x0
  pushl $235
8010701d:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80107022:	e9 70 ef ff ff       	jmp    80105f97 <alltraps>

80107027 <vector236>:
.globl vector236
vector236:
  pushl $0
80107027:	6a 00                	push   $0x0
  pushl $236
80107029:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010702e:	e9 64 ef ff ff       	jmp    80105f97 <alltraps>

80107033 <vector237>:
.globl vector237
vector237:
  pushl $0
80107033:	6a 00                	push   $0x0
  pushl $237
80107035:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
8010703a:	e9 58 ef ff ff       	jmp    80105f97 <alltraps>

8010703f <vector238>:
.globl vector238
vector238:
  pushl $0
8010703f:	6a 00                	push   $0x0
  pushl $238
80107041:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107046:	e9 4c ef ff ff       	jmp    80105f97 <alltraps>

8010704b <vector239>:
.globl vector239
vector239:
  pushl $0
8010704b:	6a 00                	push   $0x0
  pushl $239
8010704d:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80107052:	e9 40 ef ff ff       	jmp    80105f97 <alltraps>

80107057 <vector240>:
.globl vector240
vector240:
  pushl $0
80107057:	6a 00                	push   $0x0
  pushl $240
80107059:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010705e:	e9 34 ef ff ff       	jmp    80105f97 <alltraps>

80107063 <vector241>:
.globl vector241
vector241:
  pushl $0
80107063:	6a 00                	push   $0x0
  pushl $241
80107065:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
8010706a:	e9 28 ef ff ff       	jmp    80105f97 <alltraps>

8010706f <vector242>:
.globl vector242
vector242:
  pushl $0
8010706f:	6a 00                	push   $0x0
  pushl $242
80107071:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107076:	e9 1c ef ff ff       	jmp    80105f97 <alltraps>

8010707b <vector243>:
.globl vector243
vector243:
  pushl $0
8010707b:	6a 00                	push   $0x0
  pushl $243
8010707d:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80107082:	e9 10 ef ff ff       	jmp    80105f97 <alltraps>

80107087 <vector244>:
.globl vector244
vector244:
  pushl $0
80107087:	6a 00                	push   $0x0
  pushl $244
80107089:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
8010708e:	e9 04 ef ff ff       	jmp    80105f97 <alltraps>

80107093 <vector245>:
.globl vector245
vector245:
  pushl $0
80107093:	6a 00                	push   $0x0
  pushl $245
80107095:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
8010709a:	e9 f8 ee ff ff       	jmp    80105f97 <alltraps>

8010709f <vector246>:
.globl vector246
vector246:
  pushl $0
8010709f:	6a 00                	push   $0x0
  pushl $246
801070a1:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801070a6:	e9 ec ee ff ff       	jmp    80105f97 <alltraps>

801070ab <vector247>:
.globl vector247
vector247:
  pushl $0
801070ab:	6a 00                	push   $0x0
  pushl $247
801070ad:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801070b2:	e9 e0 ee ff ff       	jmp    80105f97 <alltraps>

801070b7 <vector248>:
.globl vector248
vector248:
  pushl $0
801070b7:	6a 00                	push   $0x0
  pushl $248
801070b9:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801070be:	e9 d4 ee ff ff       	jmp    80105f97 <alltraps>

801070c3 <vector249>:
.globl vector249
vector249:
  pushl $0
801070c3:	6a 00                	push   $0x0
  pushl $249
801070c5:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801070ca:	e9 c8 ee ff ff       	jmp    80105f97 <alltraps>

801070cf <vector250>:
.globl vector250
vector250:
  pushl $0
801070cf:	6a 00                	push   $0x0
  pushl $250
801070d1:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801070d6:	e9 bc ee ff ff       	jmp    80105f97 <alltraps>

801070db <vector251>:
.globl vector251
vector251:
  pushl $0
801070db:	6a 00                	push   $0x0
  pushl $251
801070dd:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801070e2:	e9 b0 ee ff ff       	jmp    80105f97 <alltraps>

801070e7 <vector252>:
.globl vector252
vector252:
  pushl $0
801070e7:	6a 00                	push   $0x0
  pushl $252
801070e9:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
801070ee:	e9 a4 ee ff ff       	jmp    80105f97 <alltraps>

801070f3 <vector253>:
.globl vector253
vector253:
  pushl $0
801070f3:	6a 00                	push   $0x0
  pushl $253
801070f5:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
801070fa:	e9 98 ee ff ff       	jmp    80105f97 <alltraps>

801070ff <vector254>:
.globl vector254
vector254:
  pushl $0
801070ff:	6a 00                	push   $0x0
  pushl $254
80107101:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107106:	e9 8c ee ff ff       	jmp    80105f97 <alltraps>

8010710b <vector255>:
.globl vector255
vector255:
  pushl $0
8010710b:	6a 00                	push   $0x0
  pushl $255
8010710d:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80107112:	e9 80 ee ff ff       	jmp    80105f97 <alltraps>
80107117:	66 90                	xchg   %ax,%ax
80107119:	66 90                	xchg   %ax,%ax
8010711b:	66 90                	xchg   %ax,%ax
8010711d:	66 90                	xchg   %ax,%ax
8010711f:	90                   	nop

80107120 <deallocuvm.part.0>:
// Deallocate user pages to bring the process size from oldsz to
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107120:	55                   	push   %ebp
80107121:	89 e5                	mov    %esp,%ebp
80107123:	57                   	push   %edi
80107124:	56                   	push   %esi
80107125:	53                   	push   %ebx
  uint a, pa;

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
80107126:	8d 99 ff 0f 00 00    	lea    0xfff(%ecx),%ebx
8010712c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
80107132:	83 ec 1c             	sub    $0x1c,%esp
80107135:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  for(; a  < oldsz; a += PGSIZE){
80107138:	39 d3                	cmp    %edx,%ebx
8010713a:	73 49                	jae    80107185 <deallocuvm.part.0+0x65>
8010713c:	89 c7                	mov    %eax,%edi
8010713e:	eb 0c                	jmp    8010714c <deallocuvm.part.0+0x2c>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
80107140:	83 c0 01             	add    $0x1,%eax
80107143:	c1 e0 16             	shl    $0x16,%eax
80107146:	89 c3                	mov    %eax,%ebx
  for(; a  < oldsz; a += PGSIZE){
80107148:	39 da                	cmp    %ebx,%edx
8010714a:	76 39                	jbe    80107185 <deallocuvm.part.0+0x65>
  pde = &pgdir[PDX(va)];
8010714c:	89 d8                	mov    %ebx,%eax
8010714e:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80107151:	8b 0c 87             	mov    (%edi,%eax,4),%ecx
80107154:	f6 c1 01             	test   $0x1,%cl
80107157:	74 e7                	je     80107140 <deallocuvm.part.0+0x20>
  return &pgtab[PTX(va)];
80107159:	89 de                	mov    %ebx,%esi
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010715b:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
80107161:	c1 ee 0a             	shr    $0xa,%esi
80107164:	81 e6 fc 0f 00 00    	and    $0xffc,%esi
8010716a:	8d b4 31 00 00 00 80 	lea    -0x80000000(%ecx,%esi,1),%esi
    if(!pte)
80107171:	85 f6                	test   %esi,%esi
80107173:	74 cb                	je     80107140 <deallocuvm.part.0+0x20>
    else if((*pte & PTE_P) != 0){
80107175:	8b 06                	mov    (%esi),%eax
80107177:	a8 01                	test   $0x1,%al
80107179:	75 15                	jne    80107190 <deallocuvm.part.0+0x70>
  for(; a  < oldsz; a += PGSIZE){
8010717b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107181:	39 da                	cmp    %ebx,%edx
80107183:	77 c7                	ja     8010714c <deallocuvm.part.0+0x2c>
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
}
80107185:	8b 45 e0             	mov    -0x20(%ebp),%eax
80107188:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010718b:	5b                   	pop    %ebx
8010718c:	5e                   	pop    %esi
8010718d:	5f                   	pop    %edi
8010718e:	5d                   	pop    %ebp
8010718f:	c3                   	ret    
      if(pa == 0)
80107190:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107195:	74 25                	je     801071bc <deallocuvm.part.0+0x9c>
      kfree(v);
80107197:	83 ec 0c             	sub    $0xc,%esp
      char *v = P2V(pa);
8010719a:	05 00 00 00 80       	add    $0x80000000,%eax
8010719f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801071a2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
      kfree(v);
801071a8:	50                   	push   %eax
801071a9:	e8 22 b3 ff ff       	call   801024d0 <kfree>
      *pte = 0;
801071ae:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
  for(; a  < oldsz; a += PGSIZE){
801071b4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801071b7:	83 c4 10             	add    $0x10,%esp
801071ba:	eb 8c                	jmp    80107148 <deallocuvm.part.0+0x28>
        panic("kfree");
801071bc:	83 ec 0c             	sub    $0xc,%esp
801071bf:	68 06 7e 10 80       	push   $0x80107e06
801071c4:	e8 b7 91 ff ff       	call   80100380 <panic>
801071c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801071d0 <seginit>:
{
801071d0:	55                   	push   %ebp
801071d1:	89 e5                	mov    %esp,%ebp
801071d3:	83 ec 18             	sub    $0x18,%esp
  c = &cpus[cpuid()];
801071d6:	e8 b5 c7 ff ff       	call   80103990 <cpuid>
  pd[0] = size-1;
801071db:	ba 2f 00 00 00       	mov    $0x2f,%edx
801071e0:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
801071e6:	66 89 55 f2          	mov    %dx,-0xe(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801071ea:	c7 80 18 28 11 80 ff 	movl   $0xffff,-0x7feed7e8(%eax)
801071f1:	ff 00 00 
801071f4:	c7 80 1c 28 11 80 00 	movl   $0xcf9a00,-0x7feed7e4(%eax)
801071fb:	9a cf 00 
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
801071fe:	c7 80 20 28 11 80 ff 	movl   $0xffff,-0x7feed7e0(%eax)
80107205:	ff 00 00 
80107208:	c7 80 24 28 11 80 00 	movl   $0xcf9200,-0x7feed7dc(%eax)
8010720f:	92 cf 00 
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107212:	c7 80 28 28 11 80 ff 	movl   $0xffff,-0x7feed7d8(%eax)
80107219:	ff 00 00 
8010721c:	c7 80 2c 28 11 80 00 	movl   $0xcffa00,-0x7feed7d4(%eax)
80107223:	fa cf 00 
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107226:	c7 80 30 28 11 80 ff 	movl   $0xffff,-0x7feed7d0(%eax)
8010722d:	ff 00 00 
80107230:	c7 80 34 28 11 80 00 	movl   $0xcff200,-0x7feed7cc(%eax)
80107237:	f2 cf 00 
  lgdt(c->gdt, sizeof(c->gdt));
8010723a:	05 10 28 11 80       	add    $0x80112810,%eax
  pd[1] = (uint)p;
8010723f:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80107243:	c1 e8 10             	shr    $0x10,%eax
80107246:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010724a:	8d 45 f2             	lea    -0xe(%ebp),%eax
8010724d:	0f 01 10             	lgdtl  (%eax)
}
80107250:	c9                   	leave  
80107251:	c3                   	ret    
80107252:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107260 <walkpgdir>:
{
80107260:	55                   	push   %ebp
80107261:	89 e5                	mov    %esp,%ebp
80107263:	57                   	push   %edi
80107264:	56                   	push   %esi
80107265:	53                   	push   %ebx
80107266:	83 ec 0c             	sub    $0xc,%esp
80107269:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pde = &pgdir[PDX(va)];
8010726c:	8b 55 08             	mov    0x8(%ebp),%edx
8010726f:	89 fe                	mov    %edi,%esi
80107271:	c1 ee 16             	shr    $0x16,%esi
80107274:	8d 34 b2             	lea    (%edx,%esi,4),%esi
  if(*pde & PTE_P){
80107277:	8b 1e                	mov    (%esi),%ebx
80107279:	f6 c3 01             	test   $0x1,%bl
8010727c:	74 22                	je     801072a0 <walkpgdir+0x40>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
8010727e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80107284:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
  return &pgtab[PTX(va)];
8010728a:	89 f8                	mov    %edi,%eax
}
8010728c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return &pgtab[PTX(va)];
8010728f:	c1 e8 0a             	shr    $0xa,%eax
80107292:	25 fc 0f 00 00       	and    $0xffc,%eax
80107297:	01 d8                	add    %ebx,%eax
}
80107299:	5b                   	pop    %ebx
8010729a:	5e                   	pop    %esi
8010729b:	5f                   	pop    %edi
8010729c:	5d                   	pop    %ebp
8010729d:	c3                   	ret    
8010729e:	66 90                	xchg   %ax,%ax
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
801072a0:	8b 45 10             	mov    0x10(%ebp),%eax
801072a3:	85 c0                	test   %eax,%eax
801072a5:	74 31                	je     801072d8 <walkpgdir+0x78>
801072a7:	e8 e4 b3 ff ff       	call   80102690 <kalloc>
801072ac:	89 c3                	mov    %eax,%ebx
801072ae:	85 c0                	test   %eax,%eax
801072b0:	74 26                	je     801072d8 <walkpgdir+0x78>
    memset(pgtab, 0, PGSIZE);
801072b2:	83 ec 04             	sub    $0x4,%esp
801072b5:	68 00 10 00 00       	push   $0x1000
801072ba:	6a 00                	push   $0x0
801072bc:	50                   	push   %eax
801072bd:	e8 6e d9 ff ff       	call   80104c30 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
801072c2:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801072c8:	83 c4 10             	add    $0x10,%esp
801072cb:	83 c8 07             	or     $0x7,%eax
801072ce:	89 06                	mov    %eax,(%esi)
801072d0:	eb b8                	jmp    8010728a <walkpgdir+0x2a>
801072d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
}
801072d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return 0;
801072db:	31 c0                	xor    %eax,%eax
}
801072dd:	5b                   	pop    %ebx
801072de:	5e                   	pop    %esi
801072df:	5f                   	pop    %edi
801072e0:	5d                   	pop    %ebp
801072e1:	c3                   	ret    
801072e2:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801072e9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

801072f0 <mappages>:
{
801072f0:	55                   	push   %ebp
801072f1:	89 e5                	mov    %esp,%ebp
801072f3:	57                   	push   %edi
801072f4:	56                   	push   %esi
801072f5:	53                   	push   %ebx
801072f6:	83 ec 1c             	sub    $0x1c,%esp
801072f9:	8b 45 0c             	mov    0xc(%ebp),%eax
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
801072fc:	8b 55 10             	mov    0x10(%ebp),%edx
  a = (char*)PGROUNDDOWN((uint)va);
801072ff:	89 c3                	mov    %eax,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107301:	8d 44 10 ff          	lea    -0x1(%eax,%edx,1),%eax
80107305:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  a = (char*)PGROUNDDOWN((uint)va);
8010730a:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107310:	89 45 e0             	mov    %eax,-0x20(%ebp)
80107313:	8b 45 14             	mov    0x14(%ebp),%eax
80107316:	29 d8                	sub    %ebx,%eax
80107318:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010731b:	eb 3a                	jmp    80107357 <mappages+0x67>
8010731d:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107320:	89 da                	mov    %ebx,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107322:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
80107327:	c1 ea 0a             	shr    $0xa,%edx
8010732a:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
80107330:	8d 84 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%eax
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107337:	85 c0                	test   %eax,%eax
80107339:	74 75                	je     801073b0 <mappages+0xc0>
    if(*pte & PTE_P)
8010733b:	f6 00 01             	testb  $0x1,(%eax)
8010733e:	0f 85 86 00 00 00    	jne    801073ca <mappages+0xda>
    *pte = pa | perm | PTE_P;
80107344:	0b 75 18             	or     0x18(%ebp),%esi
80107347:	83 ce 01             	or     $0x1,%esi
8010734a:	89 30                	mov    %esi,(%eax)
    if(a == last)
8010734c:	3b 5d e0             	cmp    -0x20(%ebp),%ebx
8010734f:	74 6f                	je     801073c0 <mappages+0xd0>
    a += PGSIZE;
80107351:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  for(;;){
80107357:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  pde = &pgdir[PDX(va)];
8010735a:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010735d:	8d 34 18             	lea    (%eax,%ebx,1),%esi
80107360:	89 d8                	mov    %ebx,%eax
80107362:	c1 e8 16             	shr    $0x16,%eax
80107365:	8d 3c 81             	lea    (%ecx,%eax,4),%edi
  if(*pde & PTE_P){
80107368:	8b 07                	mov    (%edi),%eax
8010736a:	a8 01                	test   $0x1,%al
8010736c:	75 b2                	jne    80107320 <mappages+0x30>
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
8010736e:	e8 1d b3 ff ff       	call   80102690 <kalloc>
80107373:	85 c0                	test   %eax,%eax
80107375:	74 39                	je     801073b0 <mappages+0xc0>
    memset(pgtab, 0, PGSIZE);
80107377:	83 ec 04             	sub    $0x4,%esp
8010737a:	89 45 dc             	mov    %eax,-0x24(%ebp)
8010737d:	68 00 10 00 00       	push   $0x1000
80107382:	6a 00                	push   $0x0
80107384:	50                   	push   %eax
80107385:	e8 a6 d8 ff ff       	call   80104c30 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
8010738a:	8b 55 dc             	mov    -0x24(%ebp),%edx
  return &pgtab[PTX(va)];
8010738d:	83 c4 10             	add    $0x10,%esp
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80107390:	8d 82 00 00 00 80    	lea    -0x80000000(%edx),%eax
80107396:	83 c8 07             	or     $0x7,%eax
80107399:	89 07                	mov    %eax,(%edi)
  return &pgtab[PTX(va)];
8010739b:	89 d8                	mov    %ebx,%eax
8010739d:	c1 e8 0a             	shr    $0xa,%eax
801073a0:	25 fc 0f 00 00       	and    $0xffc,%eax
801073a5:	01 d0                	add    %edx,%eax
801073a7:	eb 92                	jmp    8010733b <mappages+0x4b>
801073a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
}
801073b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
801073b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
801073b8:	5b                   	pop    %ebx
801073b9:	5e                   	pop    %esi
801073ba:	5f                   	pop    %edi
801073bb:	5d                   	pop    %ebp
801073bc:	c3                   	ret    
801073bd:	8d 76 00             	lea    0x0(%esi),%esi
801073c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
801073c3:	31 c0                	xor    %eax,%eax
}
801073c5:	5b                   	pop    %ebx
801073c6:	5e                   	pop    %esi
801073c7:	5f                   	pop    %edi
801073c8:	5d                   	pop    %ebp
801073c9:	c3                   	ret    
      panic("remap");
801073ca:	83 ec 0c             	sub    $0xc,%esp
801073cd:	68 b4 84 10 80       	push   $0x801084b4
801073d2:	e8 a9 8f ff ff       	call   80100380 <panic>
801073d7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801073de:	66 90                	xchg   %ax,%ax

801073e0 <switchkvm>:
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801073e0:	a1 e0 a5 51 80       	mov    0x8051a5e0,%eax
801073e5:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801073ea:	0f 22 d8             	mov    %eax,%cr3
}
801073ed:	c3                   	ret    
801073ee:	66 90                	xchg   %ax,%ax

801073f0 <switchuvm>:
{
801073f0:	55                   	push   %ebp
801073f1:	89 e5                	mov    %esp,%ebp
801073f3:	57                   	push   %edi
801073f4:	56                   	push   %esi
801073f5:	53                   	push   %ebx
801073f6:	83 ec 1c             	sub    $0x1c,%esp
801073f9:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801073fc:	85 f6                	test   %esi,%esi
801073fe:	0f 84 cb 00 00 00    	je     801074cf <switchuvm+0xdf>
  if(p->kstack == 0)
80107404:	8b 46 08             	mov    0x8(%esi),%eax
80107407:	85 c0                	test   %eax,%eax
80107409:	0f 84 da 00 00 00    	je     801074e9 <switchuvm+0xf9>
  if(p->pgdir == 0)
8010740f:	8b 46 04             	mov    0x4(%esi),%eax
80107412:	85 c0                	test   %eax,%eax
80107414:	0f 84 c2 00 00 00    	je     801074dc <switchuvm+0xec>
  pushcli();
8010741a:	e8 01 d6 ff ff       	call   80104a20 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010741f:	e8 0c c5 ff ff       	call   80103930 <mycpu>
80107424:	89 c3                	mov    %eax,%ebx
80107426:	e8 05 c5 ff ff       	call   80103930 <mycpu>
8010742b:	89 c7                	mov    %eax,%edi
8010742d:	e8 fe c4 ff ff       	call   80103930 <mycpu>
80107432:	83 c7 08             	add    $0x8,%edi
80107435:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80107438:	e8 f3 c4 ff ff       	call   80103930 <mycpu>
8010743d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80107440:	ba 67 00 00 00       	mov    $0x67,%edx
80107445:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010744c:	83 c0 08             	add    $0x8,%eax
8010744f:	66 89 93 98 00 00 00 	mov    %dx,0x98(%ebx)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80107456:	bf ff ff ff ff       	mov    $0xffffffff,%edi
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
8010745b:	83 c1 08             	add    $0x8,%ecx
8010745e:	c1 e8 18             	shr    $0x18,%eax
80107461:	c1 e9 10             	shr    $0x10,%ecx
80107464:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
8010746a:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80107470:	b9 99 40 00 00       	mov    $0x4099,%ecx
80107475:	66 89 8b 9d 00 00 00 	mov    %cx,0x9d(%ebx)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010747c:	bb 10 00 00 00       	mov    $0x10,%ebx
  mycpu()->gdt[SEG_TSS].s = 0;
80107481:	e8 aa c4 ff ff       	call   80103930 <mycpu>
80107486:	80 a0 9d 00 00 00 ef 	andb   $0xef,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010748d:	e8 9e c4 ff ff       	call   80103930 <mycpu>
80107492:	66 89 58 10          	mov    %bx,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80107496:	8b 5e 08             	mov    0x8(%esi),%ebx
80107499:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010749f:	e8 8c c4 ff ff       	call   80103930 <mycpu>
801074a4:	89 58 0c             	mov    %ebx,0xc(%eax)
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801074a7:	e8 84 c4 ff ff       	call   80103930 <mycpu>
801074ac:	66 89 78 6e          	mov    %di,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801074b0:	b8 28 00 00 00       	mov    $0x28,%eax
801074b5:	0f 00 d8             	ltr    %ax
  lcr3(V2P(p->pgdir));  // switch to process's address space
801074b8:	8b 46 04             	mov    0x4(%esi),%eax
801074bb:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801074c0:	0f 22 d8             	mov    %eax,%cr3
}
801074c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801074c6:	5b                   	pop    %ebx
801074c7:	5e                   	pop    %esi
801074c8:	5f                   	pop    %edi
801074c9:	5d                   	pop    %ebp
  popcli();
801074ca:	e9 a1 d5 ff ff       	jmp    80104a70 <popcli>
    panic("switchuvm: no process");
801074cf:	83 ec 0c             	sub    $0xc,%esp
801074d2:	68 ba 84 10 80       	push   $0x801084ba
801074d7:	e8 a4 8e ff ff       	call   80100380 <panic>
    panic("switchuvm: no pgdir");
801074dc:	83 ec 0c             	sub    $0xc,%esp
801074df:	68 e5 84 10 80       	push   $0x801084e5
801074e4:	e8 97 8e ff ff       	call   80100380 <panic>
    panic("switchuvm: no kstack");
801074e9:	83 ec 0c             	sub    $0xc,%esp
801074ec:	68 d0 84 10 80       	push   $0x801084d0
801074f1:	e8 8a 8e ff ff       	call   80100380 <panic>
801074f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801074fd:	8d 76 00             	lea    0x0(%esi),%esi

80107500 <inituvm>:
{
80107500:	55                   	push   %ebp
80107501:	89 e5                	mov    %esp,%ebp
80107503:	57                   	push   %edi
80107504:	56                   	push   %esi
80107505:	53                   	push   %ebx
80107506:	83 ec 1c             	sub    $0x1c,%esp
80107509:	8b 75 10             	mov    0x10(%ebp),%esi
8010750c:	8b 55 08             	mov    0x8(%ebp),%edx
8010750f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(sz >= PGSIZE)
80107512:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80107518:	77 50                	ja     8010756a <inituvm+0x6a>
8010751a:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  mem = kalloc();
8010751d:	e8 6e b1 ff ff       	call   80102690 <kalloc>
  memset(mem, 0, PGSIZE);
80107522:	83 ec 04             	sub    $0x4,%esp
80107525:	68 00 10 00 00       	push   $0x1000
  mem = kalloc();
8010752a:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
8010752c:	6a 00                	push   $0x0
8010752e:	50                   	push   %eax
8010752f:	e8 fc d6 ff ff       	call   80104c30 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80107534:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80107537:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010753d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
80107544:	50                   	push   %eax
80107545:	68 00 10 00 00       	push   $0x1000
8010754a:	6a 00                	push   $0x0
8010754c:	52                   	push   %edx
8010754d:	e8 9e fd ff ff       	call   801072f0 <mappages>
  memmove(mem, init, sz);
80107552:	89 75 10             	mov    %esi,0x10(%ebp)
80107555:	83 c4 20             	add    $0x20,%esp
80107558:	89 7d 0c             	mov    %edi,0xc(%ebp)
8010755b:	89 5d 08             	mov    %ebx,0x8(%ebp)
}
8010755e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107561:	5b                   	pop    %ebx
80107562:	5e                   	pop    %esi
80107563:	5f                   	pop    %edi
80107564:	5d                   	pop    %ebp
  memmove(mem, init, sz);
80107565:	e9 66 d7 ff ff       	jmp    80104cd0 <memmove>
    panic("inituvm: more than a page");
8010756a:	83 ec 0c             	sub    $0xc,%esp
8010756d:	68 f9 84 10 80       	push   $0x801084f9
80107572:	e8 09 8e ff ff       	call   80100380 <panic>
80107577:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010757e:	66 90                	xchg   %ax,%ax

80107580 <loaduvm>:
{
80107580:	55                   	push   %ebp
80107581:	89 e5                	mov    %esp,%ebp
80107583:	57                   	push   %edi
80107584:	56                   	push   %esi
80107585:	53                   	push   %ebx
80107586:	83 ec 1c             	sub    $0x1c,%esp
80107589:	8b 45 0c             	mov    0xc(%ebp),%eax
  if((uint) addr % PGSIZE != 0)
8010758c:	a9 ff 0f 00 00       	test   $0xfff,%eax
80107591:	0f 85 ce 00 00 00    	jne    80107665 <loaduvm+0xe5>
  for(i = 0; i < sz; i += PGSIZE){
80107597:	8b 5d 18             	mov    0x18(%ebp),%ebx
8010759a:	01 d8                	add    %ebx,%eax
8010759c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010759f:	8b 45 14             	mov    0x14(%ebp),%eax
801075a2:	01 d8                	add    %ebx,%eax
801075a4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(i = 0; i < sz; i += PGSIZE){
801075a7:	85 db                	test   %ebx,%ebx
801075a9:	0f 84 9a 00 00 00    	je     80107649 <loaduvm+0xc9>
801075af:	90                   	nop
  pde = &pgdir[PDX(va)];
801075b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  if(*pde & PTE_P){
801075b3:	8b 7d 08             	mov    0x8(%ebp),%edi
801075b6:	29 d8                	sub    %ebx,%eax
  pde = &pgdir[PDX(va)];
801075b8:	89 c2                	mov    %eax,%edx
801075ba:	c1 ea 16             	shr    $0x16,%edx
  if(*pde & PTE_P){
801075bd:	8b 14 97             	mov    (%edi,%edx,4),%edx
801075c0:	f6 c2 01             	test   $0x1,%dl
801075c3:	75 13                	jne    801075d8 <loaduvm+0x58>
      panic("loaduvm: address should exist");
801075c5:	83 ec 0c             	sub    $0xc,%esp
801075c8:	68 13 85 10 80       	push   $0x80108513
801075cd:	e8 ae 8d ff ff       	call   80100380 <panic>
801075d2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
801075d8:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801075db:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
801075e1:	25 fc 0f 00 00       	and    $0xffc,%eax
801075e6:	8d bc 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%edi
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801075ed:	85 ff                	test   %edi,%edi
801075ef:	74 d4                	je     801075c5 <loaduvm+0x45>
    pa = PTE_ADDR(*pte);
801075f1:	8b 07                	mov    (%edi),%eax
    if(readi(ip, P2V(pa), offset+i, n) != n)
801075f3:	8b 4d e0             	mov    -0x20(%ebp),%ecx
    if(sz - i < PGSIZE)
801075f6:	be 00 10 00 00       	mov    $0x1000,%esi
    pa = PTE_ADDR(*pte);
801075fb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80107600:	81 fb ff 0f 00 00    	cmp    $0xfff,%ebx
80107606:	0f 46 f3             	cmovbe %ebx,%esi
    if(readi(ip, P2V(pa), offset+i, n) != n)
80107609:	29 d9                	sub    %ebx,%ecx
8010760b:	05 00 00 00 80       	add    $0x80000000,%eax
80107610:	56                   	push   %esi
80107611:	51                   	push   %ecx
80107612:	50                   	push   %eax
80107613:	ff 75 10             	push   0x10(%ebp)
80107616:	e8 85 a4 ff ff       	call   80101aa0 <readi>
8010761b:	83 c4 10             	add    $0x10,%esp
8010761e:	39 f0                	cmp    %esi,%eax
80107620:	75 36                	jne    80107658 <loaduvm+0xd8>
      *pte |= PTE_W;
80107622:	8b 07                	mov    (%edi),%eax
80107624:	89 c2                	mov    %eax,%edx
80107626:	83 e0 fd             	and    $0xfffffffd,%eax
80107629:	83 ca 02             	or     $0x2,%edx
8010762c:	f6 45 1c 02          	testb  $0x2,0x1c(%ebp)
80107630:	0f 45 c2             	cmovne %edx,%eax
  for(i = 0; i < sz; i += PGSIZE){
80107633:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
80107639:	89 07                	mov    %eax,(%edi)
8010763b:	8b 45 18             	mov    0x18(%ebp),%eax
8010763e:	29 d8                	sub    %ebx,%eax
80107640:	39 45 18             	cmp    %eax,0x18(%ebp)
80107643:	0f 87 67 ff ff ff    	ja     801075b0 <loaduvm+0x30>
}
80107649:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
8010764c:	31 c0                	xor    %eax,%eax
}
8010764e:	5b                   	pop    %ebx
8010764f:	5e                   	pop    %esi
80107650:	5f                   	pop    %edi
80107651:	5d                   	pop    %ebp
80107652:	c3                   	ret    
80107653:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107657:	90                   	nop
80107658:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
8010765b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107660:	5b                   	pop    %ebx
80107661:	5e                   	pop    %esi
80107662:	5f                   	pop    %edi
80107663:	5d                   	pop    %ebp
80107664:	c3                   	ret    
    panic("loaduvm: addr must be page aligned");
80107665:	83 ec 0c             	sub    $0xc,%esp
80107668:	68 b4 85 10 80       	push   $0x801085b4
8010766d:	e8 0e 8d ff ff       	call   80100380 <panic>
80107672:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107679:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi

80107680 <allocuvm>:
{
80107680:	55                   	push   %ebp
80107681:	89 e5                	mov    %esp,%ebp
80107683:	57                   	push   %edi
80107684:	56                   	push   %esi
80107685:	53                   	push   %ebx
80107686:	83 ec 1c             	sub    $0x1c,%esp
  if(newsz >= KERNBASE)
80107689:	8b 7d 10             	mov    0x10(%ebp),%edi
8010768c:	85 ff                	test   %edi,%edi
8010768e:	0f 88 bc 00 00 00    	js     80107750 <allocuvm+0xd0>
  if(newsz < oldsz)
80107694:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80107697:	0f 82 a3 00 00 00    	jb     80107740 <allocuvm+0xc0>
  a = PGROUNDUP(oldsz);
8010769d:	8b 45 0c             	mov    0xc(%ebp),%eax
801076a0:	8d b0 ff 0f 00 00    	lea    0xfff(%eax),%esi
801076a6:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
  for(; a < newsz; a += PGSIZE){
801076ac:	39 75 10             	cmp    %esi,0x10(%ebp)
801076af:	0f 86 8e 00 00 00    	jbe    80107743 <allocuvm+0xc3>
801076b5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801076b8:	8b 7d 08             	mov    0x8(%ebp),%edi
801076bb:	eb 43                	jmp    80107700 <allocuvm+0x80>
801076bd:	8d 76 00             	lea    0x0(%esi),%esi
    memset(mem, 0, PGSIZE);
801076c0:	83 ec 04             	sub    $0x4,%esp
801076c3:	68 00 10 00 00       	push   $0x1000
801076c8:	6a 00                	push   $0x0
801076ca:	50                   	push   %eax
801076cb:	e8 60 d5 ff ff       	call   80104c30 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801076d0:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801076d6:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
801076dd:	50                   	push   %eax
801076de:	68 00 10 00 00       	push   $0x1000
801076e3:	56                   	push   %esi
801076e4:	57                   	push   %edi
801076e5:	e8 06 fc ff ff       	call   801072f0 <mappages>
801076ea:	83 c4 20             	add    $0x20,%esp
801076ed:	85 c0                	test   %eax,%eax
801076ef:	78 6f                	js     80107760 <allocuvm+0xe0>
  for(; a < newsz; a += PGSIZE){
801076f1:	81 c6 00 10 00 00    	add    $0x1000,%esi
801076f7:	39 75 10             	cmp    %esi,0x10(%ebp)
801076fa:	0f 86 a0 00 00 00    	jbe    801077a0 <allocuvm+0x120>
    mem = kalloc();
80107700:	e8 8b af ff ff       	call   80102690 <kalloc>
80107705:	89 c3                	mov    %eax,%ebx
    if(mem == 0){
80107707:	85 c0                	test   %eax,%eax
80107709:	75 b5                	jne    801076c0 <allocuvm+0x40>
      cprintf("allocuvm out of memory\n");
8010770b:	83 ec 0c             	sub    $0xc,%esp
8010770e:	68 31 85 10 80       	push   $0x80108531
80107713:	e8 88 8f ff ff       	call   801006a0 <cprintf>
  if(newsz >= oldsz)
80107718:	8b 45 0c             	mov    0xc(%ebp),%eax
8010771b:	83 c4 10             	add    $0x10,%esp
8010771e:	39 45 10             	cmp    %eax,0x10(%ebp)
80107721:	74 2d                	je     80107750 <allocuvm+0xd0>
80107723:	8b 55 10             	mov    0x10(%ebp),%edx
80107726:	89 c1                	mov    %eax,%ecx
80107728:	8b 45 08             	mov    0x8(%ebp),%eax
      return 0;
8010772b:	31 ff                	xor    %edi,%edi
8010772d:	e8 ee f9 ff ff       	call   80107120 <deallocuvm.part.0>
}
80107732:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107735:	89 f8                	mov    %edi,%eax
80107737:	5b                   	pop    %ebx
80107738:	5e                   	pop    %esi
80107739:	5f                   	pop    %edi
8010773a:	5d                   	pop    %ebp
8010773b:	c3                   	ret    
8010773c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
    return oldsz;
80107740:	8b 7d 0c             	mov    0xc(%ebp),%edi
}
80107743:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107746:	89 f8                	mov    %edi,%eax
80107748:	5b                   	pop    %ebx
80107749:	5e                   	pop    %esi
8010774a:	5f                   	pop    %edi
8010774b:	5d                   	pop    %ebp
8010774c:	c3                   	ret    
8010774d:	8d 76 00             	lea    0x0(%esi),%esi
80107750:	8d 65 f4             	lea    -0xc(%ebp),%esp
    return 0;
80107753:	31 ff                	xor    %edi,%edi
}
80107755:	5b                   	pop    %ebx
80107756:	89 f8                	mov    %edi,%eax
80107758:	5e                   	pop    %esi
80107759:	5f                   	pop    %edi
8010775a:	5d                   	pop    %ebp
8010775b:	c3                   	ret    
8010775c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
      cprintf("allocuvm out of memory (2)\n");
80107760:	83 ec 0c             	sub    $0xc,%esp
80107763:	68 49 85 10 80       	push   $0x80108549
80107768:	e8 33 8f ff ff       	call   801006a0 <cprintf>
  if(newsz >= oldsz)
8010776d:	8b 45 0c             	mov    0xc(%ebp),%eax
80107770:	83 c4 10             	add    $0x10,%esp
80107773:	39 45 10             	cmp    %eax,0x10(%ebp)
80107776:	74 0d                	je     80107785 <allocuvm+0x105>
80107778:	89 c1                	mov    %eax,%ecx
8010777a:	8b 55 10             	mov    0x10(%ebp),%edx
8010777d:	8b 45 08             	mov    0x8(%ebp),%eax
80107780:	e8 9b f9 ff ff       	call   80107120 <deallocuvm.part.0>
      kfree(mem);
80107785:	83 ec 0c             	sub    $0xc,%esp
      return 0;
80107788:	31 ff                	xor    %edi,%edi
      kfree(mem);
8010778a:	53                   	push   %ebx
8010778b:	e8 40 ad ff ff       	call   801024d0 <kfree>
      return 0;
80107790:	83 c4 10             	add    $0x10,%esp
}
80107793:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107796:	89 f8                	mov    %edi,%eax
80107798:	5b                   	pop    %ebx
80107799:	5e                   	pop    %esi
8010779a:	5f                   	pop    %edi
8010779b:	5d                   	pop    %ebp
8010779c:	c3                   	ret    
8010779d:	8d 76 00             	lea    0x0(%esi),%esi
801077a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801077a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801077a6:	5b                   	pop    %ebx
801077a7:	5e                   	pop    %esi
801077a8:	89 f8                	mov    %edi,%eax
801077aa:	5f                   	pop    %edi
801077ab:	5d                   	pop    %ebp
801077ac:	c3                   	ret    
801077ad:	8d 76 00             	lea    0x0(%esi),%esi

801077b0 <deallocuvm>:
{
801077b0:	55                   	push   %ebp
801077b1:	89 e5                	mov    %esp,%ebp
801077b3:	8b 55 0c             	mov    0xc(%ebp),%edx
801077b6:	8b 4d 10             	mov    0x10(%ebp),%ecx
801077b9:	8b 45 08             	mov    0x8(%ebp),%eax
  if(newsz >= oldsz)
801077bc:	39 d1                	cmp    %edx,%ecx
801077be:	73 10                	jae    801077d0 <deallocuvm+0x20>
}
801077c0:	5d                   	pop    %ebp
801077c1:	e9 5a f9 ff ff       	jmp    80107120 <deallocuvm.part.0>
801077c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801077cd:	8d 76 00             	lea    0x0(%esi),%esi
801077d0:	89 d0                	mov    %edx,%eax
801077d2:	5d                   	pop    %ebp
801077d3:	c3                   	ret    
801077d4:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801077db:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801077df:	90                   	nop

801077e0 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801077e0:	55                   	push   %ebp
801077e1:	89 e5                	mov    %esp,%ebp
801077e3:	57                   	push   %edi
801077e4:	56                   	push   %esi
801077e5:	53                   	push   %ebx
801077e6:	83 ec 0c             	sub    $0xc,%esp
801077e9:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801077ec:	85 f6                	test   %esi,%esi
801077ee:	74 59                	je     80107849 <freevm+0x69>
  if(newsz >= oldsz)
801077f0:	31 c9                	xor    %ecx,%ecx
801077f2:	ba 00 00 00 80       	mov    $0x80000000,%edx
801077f7:	89 f0                	mov    %esi,%eax
801077f9:	89 f3                	mov    %esi,%ebx
801077fb:	e8 20 f9 ff ff       	call   80107120 <deallocuvm.part.0>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80107800:	8d be 00 10 00 00    	lea    0x1000(%esi),%edi
80107806:	eb 0f                	jmp    80107817 <freevm+0x37>
80107808:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010780f:	90                   	nop
80107810:	83 c3 04             	add    $0x4,%ebx
80107813:	39 df                	cmp    %ebx,%edi
80107815:	74 23                	je     8010783a <freevm+0x5a>
    if(pgdir[i] & PTE_P){
80107817:	8b 03                	mov    (%ebx),%eax
80107819:	a8 01                	test   $0x1,%al
8010781b:	74 f3                	je     80107810 <freevm+0x30>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010781d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
      kfree(v);
80107822:	83 ec 0c             	sub    $0xc,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107825:	83 c3 04             	add    $0x4,%ebx
      char * v = P2V(PTE_ADDR(pgdir[i]));
80107828:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010782d:	50                   	push   %eax
8010782e:	e8 9d ac ff ff       	call   801024d0 <kfree>
80107833:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
80107836:	39 df                	cmp    %ebx,%edi
80107838:	75 dd                	jne    80107817 <freevm+0x37>
    }
  }
  kfree((char*)pgdir);
8010783a:	89 75 08             	mov    %esi,0x8(%ebp)
}
8010783d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107840:	5b                   	pop    %ebx
80107841:	5e                   	pop    %esi
80107842:	5f                   	pop    %edi
80107843:	5d                   	pop    %ebp
  kfree((char*)pgdir);
80107844:	e9 87 ac ff ff       	jmp    801024d0 <kfree>
    panic("freevm: no pgdir");
80107849:	83 ec 0c             	sub    $0xc,%esp
8010784c:	68 65 85 10 80       	push   $0x80108565
80107851:	e8 2a 8b ff ff       	call   80100380 <panic>
80107856:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010785d:	8d 76 00             	lea    0x0(%esi),%esi

80107860 <setupkvm>:
{
80107860:	55                   	push   %ebp
80107861:	89 e5                	mov    %esp,%ebp
80107863:	56                   	push   %esi
80107864:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80107865:	e8 26 ae ff ff       	call   80102690 <kalloc>
8010786a:	89 c6                	mov    %eax,%esi
8010786c:	85 c0                	test   %eax,%eax
8010786e:	74 42                	je     801078b2 <setupkvm+0x52>
  memset(pgdir, 0, PGSIZE);
80107870:	83 ec 04             	sub    $0x4,%esp
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107873:	bb 20 b4 10 80       	mov    $0x8010b420,%ebx
  memset(pgdir, 0, PGSIZE);
80107878:	68 00 10 00 00       	push   $0x1000
8010787d:	6a 00                	push   $0x0
8010787f:	50                   	push   %eax
80107880:	e8 ab d3 ff ff       	call   80104c30 <memset>
80107885:	83 c4 10             	add    $0x10,%esp
                (uint)k->phys_start, k->perm) < 0) {
80107888:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010788b:	8b 53 08             	mov    0x8(%ebx),%edx
8010788e:	83 ec 0c             	sub    $0xc,%esp
80107891:	ff 73 0c             	push   0xc(%ebx)
80107894:	29 c2                	sub    %eax,%edx
80107896:	50                   	push   %eax
80107897:	52                   	push   %edx
80107898:	ff 33                	push   (%ebx)
8010789a:	56                   	push   %esi
8010789b:	e8 50 fa ff ff       	call   801072f0 <mappages>
801078a0:	83 c4 20             	add    $0x20,%esp
801078a3:	85 c0                	test   %eax,%eax
801078a5:	78 19                	js     801078c0 <setupkvm+0x60>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801078a7:	83 c3 10             	add    $0x10,%ebx
801078aa:	81 fb 60 b4 10 80    	cmp    $0x8010b460,%ebx
801078b0:	75 d6                	jne    80107888 <setupkvm+0x28>
}
801078b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801078b5:	89 f0                	mov    %esi,%eax
801078b7:	5b                   	pop    %ebx
801078b8:	5e                   	pop    %esi
801078b9:	5d                   	pop    %ebp
801078ba:	c3                   	ret    
801078bb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
801078bf:	90                   	nop
      freevm(pgdir);
801078c0:	83 ec 0c             	sub    $0xc,%esp
801078c3:	56                   	push   %esi
      return 0;
801078c4:	31 f6                	xor    %esi,%esi
      freevm(pgdir);
801078c6:	e8 15 ff ff ff       	call   801077e0 <freevm>
      return 0;
801078cb:	83 c4 10             	add    $0x10,%esp
}
801078ce:	8d 65 f8             	lea    -0x8(%ebp),%esp
801078d1:	89 f0                	mov    %esi,%eax
801078d3:	5b                   	pop    %ebx
801078d4:	5e                   	pop    %esi
801078d5:	5d                   	pop    %ebp
801078d6:	c3                   	ret    
801078d7:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
801078de:	66 90                	xchg   %ax,%ax

801078e0 <kvmalloc>:
{
801078e0:	55                   	push   %ebp
801078e1:	89 e5                	mov    %esp,%ebp
801078e3:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
801078e6:	e8 75 ff ff ff       	call   80107860 <setupkvm>
801078eb:	a3 e0 a5 51 80       	mov    %eax,0x8051a5e0
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801078f0:	05 00 00 00 80       	add    $0x80000000,%eax
801078f5:	0f 22 d8             	mov    %eax,%cr3
}
801078f8:	c9                   	leave  
801078f9:	c3                   	ret    
801078fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi

80107900 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80107900:	55                   	push   %ebp
80107901:	89 e5                	mov    %esp,%ebp
80107903:	83 ec 08             	sub    $0x8,%esp
80107906:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107909:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
8010790c:	89 c1                	mov    %eax,%ecx
8010790e:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
80107911:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107914:	f6 c2 01             	test   $0x1,%dl
80107917:	75 17                	jne    80107930 <clearpteu+0x30>
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
  if(pte == 0)
    panic("clearpteu");
80107919:	83 ec 0c             	sub    $0xc,%esp
8010791c:	68 76 85 10 80       	push   $0x80108576
80107921:	e8 5a 8a ff ff       	call   80100380 <panic>
80107926:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010792d:	8d 76 00             	lea    0x0(%esi),%esi
  return &pgtab[PTX(va)];
80107930:	c1 e8 0a             	shr    $0xa,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107933:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  return &pgtab[PTX(va)];
80107939:	25 fc 0f 00 00       	and    $0xffc,%eax
8010793e:	8d 84 02 00 00 00 80 	lea    -0x80000000(%edx,%eax,1),%eax
  if(pte == 0)
80107945:	85 c0                	test   %eax,%eax
80107947:	74 d0                	je     80107919 <clearpteu+0x19>
  *pte &= ~PTE_U;
80107949:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010794c:	c9                   	leave  
8010794d:	c3                   	ret    
8010794e:	66 90                	xchg   %ax,%ax

80107950 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80107950:	55                   	push   %ebp
80107951:	89 e5                	mov    %esp,%ebp
80107953:	57                   	push   %edi
80107954:	56                   	push   %esi
80107955:	53                   	push   %ebx
80107956:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;

  // setups new page directory for the child process
  if((d = setupkvm()) == 0)
80107959:	e8 02 ff ff ff       	call   80107860 <setupkvm>
8010795e:	89 c7                	mov    %eax,%edi
80107960:	85 c0                	test   %eax,%eax
80107962:	0f 84 b4 00 00 00    	je     80107a1c <copyuvm+0xcc>
    return 0;

  // walk through parent's page table
  for(i = 0; i < sz; i += PGSIZE) {
80107968:	8b 45 0c             	mov    0xc(%ebp),%eax
8010796b:	85 c0                	test   %eax,%eax
8010796d:	0f 84 9e 00 00 00    	je     80107a11 <copyuvm+0xc1>
80107973:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80107976:	31 f6                	xor    %esi,%esi
80107978:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
8010797f:	90                   	nop
  if(*pde & PTE_P){
80107980:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107983:	89 f0                	mov    %esi,%eax
80107985:	c1 e8 16             	shr    $0x16,%eax
  if(*pde & PTE_P){
80107988:	8b 04 82             	mov    (%edx,%eax,4),%eax
8010798b:	a8 01                	test   $0x1,%al
8010798d:	75 11                	jne    801079a0 <copyuvm+0x50>
    if((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
      panic("copyuvm: pte should exist");
8010798f:	83 ec 0c             	sub    $0xc,%esp
80107992:	68 80 85 10 80       	push   $0x80108580
80107997:	e8 e4 89 ff ff       	call   80100380 <panic>
8010799c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  return &pgtab[PTX(va)];
801079a0:	89 f2                	mov    %esi,%edx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
801079a2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  return &pgtab[PTX(va)];
801079a7:	c1 ea 0a             	shr    $0xa,%edx
801079aa:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
801079b0:	8d 94 10 00 00 00 80 	lea    -0x80000000(%eax,%edx,1),%edx
    if((pte = walkpgdir(pgdir, (void *)i, 0)) == 0)
801079b7:	85 d2                	test   %edx,%edx
801079b9:	74 d4                	je     8010798f <copyuvm+0x3f>
    if(!(*pte & PTE_P))
801079bb:	8b 1a                	mov    (%edx),%ebx
801079bd:	f6 c3 01             	test   $0x1,%bl
801079c0:	0f 84 95 00 00 00    	je     80107a5b <copyuvm+0x10b>
      panic("copyuvm: page not present");

    // gets physical address and flags
    pa = PTE_ADDR(*pte);
801079c6:	89 d9                	mov    %ebx,%ecx
    flags = PTE_FLAGS(*pte);

    // handle writable pages for copy-on-write
    if(flags & PTE_W) {
      // remove write bit, set COW bit, update parent's PTE
      flags &= ~PTE_W;
801079c8:	89 d8                	mov    %ebx,%eax
    pa = PTE_ADDR(*pte);
801079ca:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
    if(flags & PTE_W) {
801079d0:	f6 c3 02             	test   $0x2,%bl
801079d3:	75 5b                	jne    80107a30 <copyuvm+0xe0>
    flags = PTE_FLAGS(*pte);
801079d5:	25 ff 0f 00 00       	and    $0xfff,%eax
      flags |= PTE_COW;
      *pte = pa | flags;
    }

    // Map the page in the child with the updated flags
    if(mappages(d, (void*)i, PGSIZE, pa, flags) < 0)
801079da:	83 ec 0c             	sub    $0xc,%esp
801079dd:	50                   	push   %eax
801079de:	51                   	push   %ecx
801079df:	68 00 10 00 00       	push   $0x1000
801079e4:	56                   	push   %esi
801079e5:	ff 75 e4             	push   -0x1c(%ebp)
801079e8:	e8 03 f9 ff ff       	call   801072f0 <mappages>
801079ed:	83 c4 20             	add    $0x20,%esp
801079f0:	85 c0                	test   %eax,%eax
801079f2:	78 4c                	js     80107a40 <copyuvm+0xf0>
      goto bad;

    // increment the reference count for the physical page
    ref_counts[pa / PGSIZE]++;
801079f4:	c1 eb 0c             	shr    $0xc,%ebx
  for(i = 0; i < sz; i += PGSIZE) {
801079f7:	81 c6 00 10 00 00    	add    $0x1000,%esi
    ref_counts[pa / PGSIZE]++;
801079fd:	83 04 9d e0 a5 11 80 	addl   $0x1,-0x7fee5a20(,%ebx,4)
80107a04:	01 
  for(i = 0; i < sz; i += PGSIZE) {
80107a05:	39 75 0c             	cmp    %esi,0xc(%ebp)
80107a08:	0f 87 72 ff ff ff    	ja     80107980 <copyuvm+0x30>
80107a0e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  }

  // flush the TLB
  lcr3(V2P(pgdir));
80107a11:	8b 45 08             	mov    0x8(%ebp),%eax
80107a14:	05 00 00 00 80       	add    $0x80000000,%eax
80107a19:	0f 22 d8             	mov    %eax,%cr3
  return d;

bad:
  freevm(d);
  return 0;
}
80107a1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107a1f:	89 f8                	mov    %edi,%eax
80107a21:	5b                   	pop    %ebx
80107a22:	5e                   	pop    %esi
80107a23:	5f                   	pop    %edi
80107a24:	5d                   	pop    %ebp
80107a25:	c3                   	ret    
80107a26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107a2d:	8d 76 00             	lea    0x0(%esi),%esi
      flags &= ~PTE_W;
80107a30:	25 fd 0f 00 00       	and    $0xffd,%eax
      *pte = pa | flags;
80107a35:	89 cf                	mov    %ecx,%edi
      flags |= PTE_COW;
80107a37:	80 cc 02             	or     $0x2,%ah
      *pte = pa | flags;
80107a3a:	09 c7                	or     %eax,%edi
80107a3c:	89 3a                	mov    %edi,(%edx)
80107a3e:	eb 9a                	jmp    801079da <copyuvm+0x8a>
  freevm(d);
80107a40:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80107a43:	83 ec 0c             	sub    $0xc,%esp
80107a46:	57                   	push   %edi
  return 0;
80107a47:	31 ff                	xor    %edi,%edi
  freevm(d);
80107a49:	e8 92 fd ff ff       	call   801077e0 <freevm>
  return 0;
80107a4e:	83 c4 10             	add    $0x10,%esp
}
80107a51:	8d 65 f4             	lea    -0xc(%ebp),%esp
80107a54:	89 f8                	mov    %edi,%eax
80107a56:	5b                   	pop    %ebx
80107a57:	5e                   	pop    %esi
80107a58:	5f                   	pop    %edi
80107a59:	5d                   	pop    %ebp
80107a5a:	c3                   	ret    
      panic("copyuvm: page not present");
80107a5b:	83 ec 0c             	sub    $0xc,%esp
80107a5e:	68 9a 85 10 80       	push   $0x8010859a
80107a63:	e8 18 89 ff ff       	call   80100380 <panic>
80107a68:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107a6f:	90                   	nop

80107a70 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80107a70:	55                   	push   %ebp
80107a71:	89 e5                	mov    %esp,%ebp
80107a73:	8b 45 0c             	mov    0xc(%ebp),%eax
  if(*pde & PTE_P){
80107a76:	8b 55 08             	mov    0x8(%ebp),%edx
  pde = &pgdir[PDX(va)];
80107a79:	89 c1                	mov    %eax,%ecx
80107a7b:	c1 e9 16             	shr    $0x16,%ecx
  if(*pde & PTE_P){
80107a7e:	8b 14 8a             	mov    (%edx,%ecx,4),%edx
80107a81:	f6 c2 01             	test   $0x1,%dl
80107a84:	0f 84 00 01 00 00    	je     80107b8a <uva2ka.cold>
  return &pgtab[PTX(va)];
80107a8a:	c1 e8 0c             	shr    $0xc,%eax
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107a8d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  if((*pte & PTE_P) == 0)
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
}
80107a93:	5d                   	pop    %ebp
  return &pgtab[PTX(va)];
80107a94:	25 ff 03 00 00       	and    $0x3ff,%eax
  if((*pte & PTE_P) == 0)
80107a99:	8b 84 82 00 00 00 80 	mov    -0x80000000(%edx,%eax,4),%eax
  if((*pte & PTE_U) == 0)
80107aa0:	89 c2                	mov    %eax,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107aa2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((*pte & PTE_U) == 0)
80107aa7:	83 e2 05             	and    $0x5,%edx
  return (char*)P2V(PTE_ADDR(*pte));
80107aaa:	05 00 00 00 80       	add    $0x80000000,%eax
80107aaf:	83 fa 05             	cmp    $0x5,%edx
80107ab2:	ba 00 00 00 00       	mov    $0x0,%edx
80107ab7:	0f 45 c2             	cmovne %edx,%eax
}
80107aba:	c3                   	ret    
80107abb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107abf:	90                   	nop

80107ac0 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80107ac0:	55                   	push   %ebp
80107ac1:	89 e5                	mov    %esp,%ebp
80107ac3:	57                   	push   %edi
80107ac4:	56                   	push   %esi
80107ac5:	53                   	push   %ebx
80107ac6:	83 ec 0c             	sub    $0xc,%esp
80107ac9:	8b 75 14             	mov    0x14(%ebp),%esi
80107acc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107acf:	8b 55 10             	mov    0x10(%ebp),%edx
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80107ad2:	85 f6                	test   %esi,%esi
80107ad4:	75 51                	jne    80107b27 <copyout+0x67>
80107ad6:	e9 a5 00 00 00       	jmp    80107b80 <copyout+0xc0>
80107adb:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
80107adf:	90                   	nop
  return (char*)P2V(PTE_ADDR(*pte));
80107ae0:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80107ae6:	8d 8b 00 00 00 80    	lea    -0x80000000(%ebx),%ecx
    va0 = (uint)PGROUNDDOWN(va);
    pa0 = uva2ka(pgdir, (char*)va0);
    if(pa0 == 0)
80107aec:	81 fb 00 00 00 80    	cmp    $0x80000000,%ebx
80107af2:	74 75                	je     80107b69 <copyout+0xa9>
      return -1;
    n = PGSIZE - (va - va0);
80107af4:	89 fb                	mov    %edi,%ebx
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80107af6:	89 55 10             	mov    %edx,0x10(%ebp)
    n = PGSIZE - (va - va0);
80107af9:	29 c3                	sub    %eax,%ebx
80107afb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80107b01:	39 f3                	cmp    %esi,%ebx
80107b03:	0f 47 de             	cmova  %esi,%ebx
    memmove(pa0 + (va - va0), buf, n);
80107b06:	29 f8                	sub    %edi,%eax
80107b08:	83 ec 04             	sub    $0x4,%esp
80107b0b:	01 c1                	add    %eax,%ecx
80107b0d:	53                   	push   %ebx
80107b0e:	52                   	push   %edx
80107b0f:	51                   	push   %ecx
80107b10:	e8 bb d1 ff ff       	call   80104cd0 <memmove>
    len -= n;
    buf += n;
80107b15:	8b 55 10             	mov    0x10(%ebp),%edx
    va = va0 + PGSIZE;
80107b18:	8d 87 00 10 00 00    	lea    0x1000(%edi),%eax
  while(len > 0){
80107b1e:	83 c4 10             	add    $0x10,%esp
    buf += n;
80107b21:	01 da                	add    %ebx,%edx
  while(len > 0){
80107b23:	29 de                	sub    %ebx,%esi
80107b25:	74 59                	je     80107b80 <copyout+0xc0>
  if(*pde & PTE_P){
80107b27:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pde = &pgdir[PDX(va)];
80107b2a:	89 c1                	mov    %eax,%ecx
    va0 = (uint)PGROUNDDOWN(va);
80107b2c:	89 c7                	mov    %eax,%edi
  pde = &pgdir[PDX(va)];
80107b2e:	c1 e9 16             	shr    $0x16,%ecx
    va0 = (uint)PGROUNDDOWN(va);
80107b31:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  if(*pde & PTE_P){
80107b37:	8b 0c 8b             	mov    (%ebx,%ecx,4),%ecx
80107b3a:	f6 c1 01             	test   $0x1,%cl
80107b3d:	0f 84 4e 00 00 00    	je     80107b91 <copyout.cold>
  return &pgtab[PTX(va)];
80107b43:	89 fb                	mov    %edi,%ebx
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80107b45:	81 e1 00 f0 ff ff    	and    $0xfffff000,%ecx
  return &pgtab[PTX(va)];
80107b4b:	c1 eb 0c             	shr    $0xc,%ebx
80107b4e:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
  if((*pte & PTE_P) == 0)
80107b54:	8b 9c 99 00 00 00 80 	mov    -0x80000000(%ecx,%ebx,4),%ebx
  if((*pte & PTE_U) == 0)
80107b5b:	89 d9                	mov    %ebx,%ecx
80107b5d:	83 e1 05             	and    $0x5,%ecx
80107b60:	83 f9 05             	cmp    $0x5,%ecx
80107b63:	0f 84 77 ff ff ff    	je     80107ae0 <copyout+0x20>
  }
  return 0;
}
80107b69:	8d 65 f4             	lea    -0xc(%ebp),%esp
      return -1;
80107b6c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80107b71:	5b                   	pop    %ebx
80107b72:	5e                   	pop    %esi
80107b73:	5f                   	pop    %edi
80107b74:	5d                   	pop    %ebp
80107b75:	c3                   	ret    
80107b76:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
80107b7d:	8d 76 00             	lea    0x0(%esi),%esi
80107b80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  return 0;
80107b83:	31 c0                	xor    %eax,%eax
}
80107b85:	5b                   	pop    %ebx
80107b86:	5e                   	pop    %esi
80107b87:	5f                   	pop    %edi
80107b88:	5d                   	pop    %ebp
80107b89:	c3                   	ret    

80107b8a <uva2ka.cold>:
  if((*pte & PTE_P) == 0)
80107b8a:	a1 00 00 00 00       	mov    0x0,%eax
80107b8f:	0f 0b                	ud2    

80107b91 <copyout.cold>:
80107b91:	a1 00 00 00 00       	mov    0x0,%eax
80107b96:	0f 0b                	ud2    
