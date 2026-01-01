package com.kkdeok.idl.apis.v1.search;

import static io.grpc.MethodDescriptor.generateFullMethodName;

/**
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.68.0)",
    comments = "Source: services/search/search.proto")
@io.grpc.stub.annotations.GrpcGenerated
public final class SearchGrpc {

  private SearchGrpc() {}

  public static final java.lang.String SERVICE_NAME = "apis.v1.search.Search";

  // Static method descriptors that strictly reflect the proto.
  private static volatile io.grpc.MethodDescriptor<com.kkdeok.idl.apis.v1.search.SearchRequest,
      com.kkdeok.idl.apis.v1.search.SearchResponse> getSearchMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "Search",
      requestType = com.kkdeok.idl.apis.v1.search.SearchRequest.class,
      responseType = com.kkdeok.idl.apis.v1.search.SearchResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.kkdeok.idl.apis.v1.search.SearchRequest,
      com.kkdeok.idl.apis.v1.search.SearchResponse> getSearchMethod() {
    io.grpc.MethodDescriptor<com.kkdeok.idl.apis.v1.search.SearchRequest, com.kkdeok.idl.apis.v1.search.SearchResponse> getSearchMethod;
    if ((getSearchMethod = SearchGrpc.getSearchMethod) == null) {
      synchronized (SearchGrpc.class) {
        if ((getSearchMethod = SearchGrpc.getSearchMethod) == null) {
          SearchGrpc.getSearchMethod = getSearchMethod =
              io.grpc.MethodDescriptor.<com.kkdeok.idl.apis.v1.search.SearchRequest, com.kkdeok.idl.apis.v1.search.SearchResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "Search"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.kkdeok.idl.apis.v1.search.SearchRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.kkdeok.idl.apis.v1.search.SearchResponse.getDefaultInstance()))
              .setSchemaDescriptor(new SearchMethodDescriptorSupplier("Search"))
              .build();
        }
      }
    }
    return getSearchMethod;
  }

  private static volatile io.grpc.MethodDescriptor<com.kkdeok.idl.apis.v1.search.SearchRequest,
      com.kkdeok.idl.apis.v1.search.SearchResponse> getHelloMethod;

  @io.grpc.stub.annotations.RpcMethod(
      fullMethodName = SERVICE_NAME + '/' + "Hello",
      requestType = com.kkdeok.idl.apis.v1.search.SearchRequest.class,
      responseType = com.kkdeok.idl.apis.v1.search.SearchResponse.class,
      methodType = io.grpc.MethodDescriptor.MethodType.UNARY)
  public static io.grpc.MethodDescriptor<com.kkdeok.idl.apis.v1.search.SearchRequest,
      com.kkdeok.idl.apis.v1.search.SearchResponse> getHelloMethod() {
    io.grpc.MethodDescriptor<com.kkdeok.idl.apis.v1.search.SearchRequest, com.kkdeok.idl.apis.v1.search.SearchResponse> getHelloMethod;
    if ((getHelloMethod = SearchGrpc.getHelloMethod) == null) {
      synchronized (SearchGrpc.class) {
        if ((getHelloMethod = SearchGrpc.getHelloMethod) == null) {
          SearchGrpc.getHelloMethod = getHelloMethod =
              io.grpc.MethodDescriptor.<com.kkdeok.idl.apis.v1.search.SearchRequest, com.kkdeok.idl.apis.v1.search.SearchResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(SERVICE_NAME, "Hello"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.kkdeok.idl.apis.v1.search.SearchRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.kkdeok.idl.apis.v1.search.SearchResponse.getDefaultInstance()))
              .setSchemaDescriptor(new SearchMethodDescriptorSupplier("Hello"))
              .build();
        }
      }
    }
    return getHelloMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static SearchStub newStub(io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<SearchStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<SearchStub>() {
        @java.lang.Override
        public SearchStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new SearchStub(channel, callOptions);
        }
      };
    return SearchStub.newStub(factory, channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static SearchBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<SearchBlockingStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<SearchBlockingStub>() {
        @java.lang.Override
        public SearchBlockingStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new SearchBlockingStub(channel, callOptions);
        }
      };
    return SearchBlockingStub.newStub(factory, channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static SearchFutureStub newFutureStub(
      io.grpc.Channel channel) {
    io.grpc.stub.AbstractStub.StubFactory<SearchFutureStub> factory =
      new io.grpc.stub.AbstractStub.StubFactory<SearchFutureStub>() {
        @java.lang.Override
        public SearchFutureStub newStub(io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
          return new SearchFutureStub(channel, callOptions);
        }
      };
    return SearchFutureStub.newStub(factory, channel);
  }

  /**
   */
  public interface AsyncService {

    /**
     */
    default void search(com.kkdeok.idl.apis.v1.search.SearchRequest request,
        io.grpc.stub.StreamObserver<com.kkdeok.idl.apis.v1.search.SearchResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getSearchMethod(), responseObserver);
    }

    /**
     */
    default void hello(com.kkdeok.idl.apis.v1.search.SearchRequest request,
        io.grpc.stub.StreamObserver<com.kkdeok.idl.apis.v1.search.SearchResponse> responseObserver) {
      io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall(getHelloMethod(), responseObserver);
    }
  }

  /**
   * Base class for the server implementation of the service Search.
   */
  public static abstract class SearchImplBase
      implements io.grpc.BindableService, AsyncService {

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return SearchGrpc.bindService(this);
    }
  }

  /**
   * A stub to allow clients to do asynchronous rpc calls to service Search.
   */
  public static final class SearchStub
      extends io.grpc.stub.AbstractAsyncStub<SearchStub> {
    private SearchStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected SearchStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new SearchStub(channel, callOptions);
    }

    /**
     */
    public void search(com.kkdeok.idl.apis.v1.search.SearchRequest request,
        io.grpc.stub.StreamObserver<com.kkdeok.idl.apis.v1.search.SearchResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getSearchMethod(), getCallOptions()), request, responseObserver);
    }

    /**
     */
    public void hello(com.kkdeok.idl.apis.v1.search.SearchRequest request,
        io.grpc.stub.StreamObserver<com.kkdeok.idl.apis.v1.search.SearchResponse> responseObserver) {
      io.grpc.stub.ClientCalls.asyncUnaryCall(
          getChannel().newCall(getHelloMethod(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   * A stub to allow clients to do synchronous rpc calls to service Search.
   */
  public static final class SearchBlockingStub
      extends io.grpc.stub.AbstractBlockingStub<SearchBlockingStub> {
    private SearchBlockingStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected SearchBlockingStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new SearchBlockingStub(channel, callOptions);
    }

    /**
     */
    public com.kkdeok.idl.apis.v1.search.SearchResponse search(com.kkdeok.idl.apis.v1.search.SearchRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getSearchMethod(), getCallOptions(), request);
    }

    /**
     */
    public com.kkdeok.idl.apis.v1.search.SearchResponse hello(com.kkdeok.idl.apis.v1.search.SearchRequest request) {
      return io.grpc.stub.ClientCalls.blockingUnaryCall(
          getChannel(), getHelloMethod(), getCallOptions(), request);
    }
  }

  /**
   * A stub to allow clients to do ListenableFuture-style rpc calls to service Search.
   */
  public static final class SearchFutureStub
      extends io.grpc.stub.AbstractFutureStub<SearchFutureStub> {
    private SearchFutureStub(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected SearchFutureStub build(
        io.grpc.Channel channel, io.grpc.CallOptions callOptions) {
      return new SearchFutureStub(channel, callOptions);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<com.kkdeok.idl.apis.v1.search.SearchResponse> search(
        com.kkdeok.idl.apis.v1.search.SearchRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getSearchMethod(), getCallOptions()), request);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<com.kkdeok.idl.apis.v1.search.SearchResponse> hello(
        com.kkdeok.idl.apis.v1.search.SearchRequest request) {
      return io.grpc.stub.ClientCalls.futureUnaryCall(
          getChannel().newCall(getHelloMethod(), getCallOptions()), request);
    }
  }

  private static final int METHODID_SEARCH = 0;
  private static final int METHODID_HELLO = 1;

  private static final class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final AsyncService serviceImpl;
    private final int methodId;

    MethodHandlers(AsyncService serviceImpl, int methodId) {
      this.serviceImpl = serviceImpl;
      this.methodId = methodId;
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        case METHODID_SEARCH:
          serviceImpl.search((com.kkdeok.idl.apis.v1.search.SearchRequest) request,
              (io.grpc.stub.StreamObserver<com.kkdeok.idl.apis.v1.search.SearchResponse>) responseObserver);
          break;
        case METHODID_HELLO:
          serviceImpl.hello((com.kkdeok.idl.apis.v1.search.SearchRequest) request,
              (io.grpc.stub.StreamObserver<com.kkdeok.idl.apis.v1.search.SearchResponse>) responseObserver);
          break;
        default:
          throw new AssertionError();
      }
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public io.grpc.stub.StreamObserver<Req> invoke(
        io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        default:
          throw new AssertionError();
      }
    }
  }

  public static final io.grpc.ServerServiceDefinition bindService(AsyncService service) {
    return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
        .addMethod(
          getSearchMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.kkdeok.idl.apis.v1.search.SearchRequest,
              com.kkdeok.idl.apis.v1.search.SearchResponse>(
                service, METHODID_SEARCH)))
        .addMethod(
          getHelloMethod(),
          io.grpc.stub.ServerCalls.asyncUnaryCall(
            new MethodHandlers<
              com.kkdeok.idl.apis.v1.search.SearchRequest,
              com.kkdeok.idl.apis.v1.search.SearchResponse>(
                service, METHODID_HELLO)))
        .build();
  }

  private static abstract class SearchBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    SearchBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return com.kkdeok.idl.apis.v1.search.SearchProto.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("Search");
    }
  }

  private static final class SearchFileDescriptorSupplier
      extends SearchBaseDescriptorSupplier {
    SearchFileDescriptorSupplier() {}
  }

  private static final class SearchMethodDescriptorSupplier
      extends SearchBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final java.lang.String methodName;

    SearchMethodDescriptorSupplier(java.lang.String methodName) {
      this.methodName = methodName;
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.MethodDescriptor getMethodDescriptor() {
      return getServiceDescriptor().findMethodByName(methodName);
    }
  }

  private static volatile io.grpc.ServiceDescriptor serviceDescriptor;

  public static io.grpc.ServiceDescriptor getServiceDescriptor() {
    io.grpc.ServiceDescriptor result = serviceDescriptor;
    if (result == null) {
      synchronized (SearchGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .setSchemaDescriptor(new SearchFileDescriptorSupplier())
              .addMethod(getSearchMethod())
              .addMethod(getHelloMethod())
              .build();
        }
      }
    }
    return result;
  }
}
