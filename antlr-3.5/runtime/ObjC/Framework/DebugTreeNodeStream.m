// [The "BSD licence"]
// Copyright (c) 2006-2007 Kay Roepke
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions
// are met:
// 1. Redistributions of source code must retain the above copyright
//    notice, this list of conditions and the following disclaimer.
// 2. Redistributions in binary form must reproduce the above copyright
//    notice, this list of conditions and the following disclaimer in the
//    documentation and/or other materials provided with the distribution.
// 3. The name of the author may not be used to endorse or promote products
//    derived from this software without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
// IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
// OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
// IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
// NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
// THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

#import "DebugTreeNodeStream.h"


@implementation DebugTreeNodeStream

- (id) initWithTreeNodeStream:(id<TreeNodeStream>)theStream debugListener:(id<DebugEventListener>)debugger
{
	self = [super init];
	if (self) {
		[self setDebugListener:debugger];
		[self setTreeAdaptor:[theStream treeAdaptor]];
		[self setInput:theStream];
	}
	return self;
}

- (void) dealloc
{
    [self setDebugListener: nil];
    [self setTreeAdaptor: nil];
    input = nil;
    [super dealloc];
}

- (id<DebugEventListener>) debugListener
{
    return debugListener; 
}

- (void) setDebugListener: (id<DebugEventListener>) aDebugListener
{
    if (debugListener != aDebugListener) {
        [(id<DebugEventListener,NSObject>)aDebugListener retain];
        [(id<DebugEventListener,NSObject>)debugListener release];
        debugListener = aDebugListener;
    }
}


- (id<TreeAdaptor>) getTreeAdaptor
{
    return treeAdaptor; 
}

- (void) setTreeAdaptor: (id<TreeAdaptor>) aTreeAdaptor
{
    if (treeAdaptor != aTreeAdaptor) {
        [(id<TreeAdaptor,NSObject>)aTreeAdaptor retain];
        [(id<TreeAdaptor,NSObject>)treeAdaptor release];
        treeAdaptor = aTreeAdaptor;
    }
}


- (id<TreeNodeStream>) input
{
    return input; 
}

- (void) setInput:(id<TreeNodeStream>) aTreeNodeStream
{
    if (input != aTreeNodeStream) {
        [input release];
        [(id<TreeNodeStream,NSObject>)aTreeNodeStream retain];
    }
    input = aTreeNodeStream;
}


#pragma mark TreeNodeStream conformance

- (id) LT:(NSInteger)k
{
	id node = [input LT:k];
	unsigned hash = [treeAdaptor uniqueIdForTree:node];
	NSString *text = [treeAdaptor textForNode:node];
	int type = [treeAdaptor tokenTypeForNode:node];
	[debugListener LT:k foundNode:hash ofType:type text:text];
	return node;
}

- (void) setUniqueNavigationNodes:(BOOL)flag
{
	[input setUniqueNavigationNodes:flag];
}

#pragma mark IntStream conformance
- (void) consume
{
	id node = [input LT:1];
	[input consume];
	unsigned hash = [treeAdaptor uniqueIdForTree:node];
	NSString *theText = [treeAdaptor textForNode:node];
	int aType = [treeAdaptor tokenTypeForNode:node];
	[debugListener consumeNode:hash ofType:aType text:theText];
}

- (NSInteger) LA:(NSUInteger) i
{
	id<BaseTree> node = [self LT:1];
	return node.type;
}

- (NSUInteger) mark
{
	unsigned lastMarker = [input mark];
	[debugListener mark:lastMarker];
	return lastMarker;
}

- (NSUInteger) getIndex
{
	return input.index;
}

- (void) rewind:(NSUInteger) marker
{
	[input rewind:marker];
	[debugListener rewind:marker];
}

- (void) rewind
{
	[input rewind];
	[debugListener rewind];
}

- (void) release:(NSUInteger) marker
{
	[input release:marker];
}

- (void) seek:(NSUInteger) index
{
	[input seek:index];
	// todo: seek missing in debug protocol
}

- (NSUInteger) size
{
	return [input size];
}

- (NSString *) toStringFromToken:(id)startNode ToToken:(id)stopNode
{
    return [input toStringFromToken:(id<Token>)startNode ToToken:(id<Token>)stopNode];
}

@end
